import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:linkflutter/core/api/api_config.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/core/network/network_status.dart';
import 'package:mime/mime.dart';

class ApiClient {
  ApiClient({http.Client? client, NetworkStatus? networkStatus})
    : _client = client ?? http.Client(),
      _networkStatus = networkStatus;

  static const _timeout = Duration(seconds: 12);

  final http.Client _client;
  final NetworkStatus? _networkStatus;
  String? _accessToken;
  void Function()? onUnauthorized;

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  String? get accessToken => _accessToken;

  Future<Map<String, dynamic>> get(
    String path, {
    bool authenticated = false,
  }) async {
    final response = await _timed(
      _client.get(
        Uri.parse('${ApiConfig.baseUrl}$path'),
        headers: _headers(authenticated: authenticated),
      ),
    );
    final data = _handleResponse(response);
    if (data is Map<String, dynamic>) return data;
    throw ApiException(
      'Réponse serveur invalide',
      statusCode: response.statusCode,
    );
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
    Duration? timeout,
  }) async {
    final response = await _timed(
      _client.post(
        Uri.parse('${ApiConfig.baseUrl}$path'),
        headers: _headers(authenticated: authenticated),
        body: body == null ? null : jsonEncode(body),
      ),
      timeout: timeout,
    );
    final data = _handleResponse(response);
    if (data is Map<String, dynamic>) return data;
    throw ApiException(
      'Réponse serveur invalide',
      statusCode: response.statusCode,
    );
  }

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) async {
    final response = await _timed(
      _client.put(
        Uri.parse('${ApiConfig.baseUrl}$path'),
        headers: _headers(authenticated: authenticated),
        body: body == null ? null : jsonEncode(body),
      ),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) async {
    final response = await _timed(
      _client.patch(
        Uri.parse('${ApiConfig.baseUrl}$path'),
        headers: _headers(authenticated: authenticated),
        body: body == null ? null : jsonEncode(body),
      ),
    );
    final data = _handleResponse(response);
    if (data is Map<String, dynamic>) return data;
    throw ApiException(
      'Réponse serveur invalide',
      statusCode: response.statusCode,
    );
  }

  Future<void> delete(String path, {bool authenticated = false}) async {
    final response = await _timed(
      _client.delete(
        Uri.parse('${ApiConfig.baseUrl}$path'),
        headers: _headers(authenticated: authenticated),
      ),
    );
    _handleResponse(response);
  }

  Future<void> deleteWithBody(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) async {
    final response = await _guard(
      _client
          .send(
            http.Request('DELETE', Uri.parse('${ApiConfig.baseUrl}$path'))
              ..headers.addAll(_headers(authenticated: authenticated))
              ..body = body == null ? '' : jsonEncode(body),
          )
          .timeout(_timeout),
    );
    _networkStatus?.reportOnline();
    final streamed = await http.Response.fromStream(response);
    _handleResponse(streamed);
  }

  Future<List<dynamic>> getList(
    String path, {
    bool authenticated = false,
  }) async {
    final response = await _timed(
      _client.get(
        Uri.parse('${ApiConfig.baseUrl}$path'),
        headers: _headers(authenticated: authenticated),
      ),
    );
    final data = _handleResponse(response);
    if (data is List<dynamic>) return data;
    if (data is Map<String, dynamic> && data['data'] is List) {
      return data['data'] as List<dynamic>;
    }
    return [];
  }

  Future<Map<String, dynamic>> uploadMultipart(
    String path, {
    required String fieldName,
    required String filePath,
    bool authenticated = false,
    String? contentType,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}$path'),
    );

    if (authenticated && _accessToken != null) {
      request.headers['Authorization'] = 'Bearer $_accessToken';
    }
    request.headers['Accept'] = 'application/json';
    request.files.add(
      await http.MultipartFile.fromPath(
        fieldName,
        filePath,
        contentType: _mediaTypeForUpload(filePath, contentType),
        filename: _uploadFilename(filePath),
      ),
    );

    final streamed = await _guard(
      _client.send(request).timeout(const Duration(seconds: 30)),
    );
    _networkStatus?.reportOnline();
    final response = await http.Response.fromStream(streamed);
    final data = _handleResponse(response);
    if (data is Map<String, dynamic>) return data;
    throw ApiException(
      'Réponse serveur invalide',
      statusCode: response.statusCode,
    );
  }

  Future<http.Response> _timed(
    Future<http.Response> request, {
    Duration? timeout,
  }) async {
    final response = await _guard(request.timeout(timeout ?? _timeout));
    _networkStatus?.reportOnline();
    return response;
  }

  Future<T> _guard<T>(Future<T> request) async {
    try {
      return await request;
    } on SocketException {
      throw _offlineException();
    } on TlsException {
      throw _offlineException();
    } on http.ClientException {
      throw _offlineException();
    } on TimeoutException {
      throw _offlineException();
    }
  }

  ApiException _offlineException() {
    _networkStatus?.reportOffline();
    return ApiException(NetworkStatus.offlineMessage, statusCode: 0);
  }

  Map<String, String> _headers({bool authenticated = false}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (authenticated && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    dynamic body;

    if (response.body.isNotEmpty) {
      try {
        body = jsonDecode(response.body);
      } catch (_) {
        throw ApiException('Réponse serveur invalide', statusCode: statusCode);
      }
    }

    if (statusCode >= 200 && statusCode < 300) {
      return body;
    }

    if (statusCode == 401 && _accessToken != null) {
      onUnauthorized?.call();
    }

    final message =
        _extractErrorMessage(body) ??
        'Une erreur est survenue (${response.statusCode})';
    throw ApiException(message, statusCode: statusCode);
  }

  String? _extractErrorMessage(dynamic body) {
    if (body is! Map<String, dynamic>) return null;

    final message = body['message'];
    if (message is String) return message;
    if (message is List && message.isNotEmpty) {
      return message.first.toString();
    }
    return null;
  }

  MediaType _mediaTypeForUpload(String filePath, String? contentType) {
    if (contentType != null) {
      final parts = contentType.split('/');
      if (parts.length == 2) {
        return MediaType(parts[0], parts[1]);
      }
    }

    final mime = lookupMimeType(filePath);
    if (mime != null) {
      final parts = mime.split('/');
      if (parts.length == 2) {
        return MediaType(parts[0], parts[1]);
      }
    }

    return MediaType('image', 'jpeg');
  }

  String _uploadFilename(String filePath) {
    final name = filePath.split(Platform.pathSeparator).last;
    if (name.isNotEmpty && name.contains('.')) return name;
    return 'upload.jpg';
  }
}
