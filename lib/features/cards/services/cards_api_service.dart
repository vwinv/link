import 'package:linkflutter/core/api/api_client.dart';
import 'package:linkflutter/features/cards/models/card_analytics.dart';
import 'package:linkflutter/features/cards/models/business_card.dart';
import 'package:linkflutter/features/cards/models/card_kind.dart';
import 'package:linkflutter/features/cards/models/card_social_link.dart';
import 'package:linkflutter/features/cards/models/card_theme_settings.dart';
import 'package:linkflutter/features/cards/models/card_visitors.dart';

class CardsApiService {
  CardsApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<BusinessCard>> fetchMyCards() async {
    final response = await _apiClient.getList(
      '/cards',
      authenticated: true,
    );

    final cards = <BusinessCard>[];
    for (final item in response) {
      if (item is! Map) continue;
      final json = Map<String, dynamic>.from(item);
      try {
        cards.add(BusinessCard.fromJson(json));
      } catch (_) {
        // Ignore malformed card payloads.
      }
    }
    return cards;
  }

  Future<BusinessCard> createCard({
    required String firstName,
    required String lastName,
    String? jobTitle,
    String? company,
    String? email,
    String? phone,
    CardKind kind = CardKind.personal,
    String? teamId,
  }) async {
    final response = await _apiClient.post(
      '/cards',
      authenticated: true,
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'kind': kind.apiValue,
        if (teamId != null && teamId.isNotEmpty) 'teamId': teamId,
        if (jobTitle != null && jobTitle.isNotEmpty) 'jobTitle': jobTitle,
        if (company != null && company.isNotEmpty) 'company': company,
        if (email != null && email.isNotEmpty) 'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      },
    );
    return BusinessCard.fromJson(response);
  }

  Future<BusinessCard> createProfessionalFromPersonal(
    BusinessCard personal, {
    required String teamId,
    required String company,
  }) {
    return createCard(
      firstName: personal.firstName,
      lastName: personal.lastName,
      jobTitle: personal.jobTitle,
      company: company,
      email: personal.email,
      phone: personal.phone,
      kind: CardKind.professional,
      teamId: teamId,
    );
  }

  Future<BusinessCard> updateCard(
    String id, {
    required String firstName,
    required String lastName,
    String? jobTitle,
    String? company,
    String? email,
    String? phone,
    String? avatarUrl,
    bool includeAvatar = false,
    String? logoUrl,
    bool includeLogo = false,
  }) async {
    final body = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'jobTitle': jobTitle ?? '',
      'company': company ?? '',
      'email': email ?? '',
      'phone': phone ?? '',
    };
    if (includeAvatar) {
      body['avatarUrl'] = avatarUrl ?? '';
    }
    if (includeLogo) {
      body['logoUrl'] = logoUrl ?? '';
    }

    final response = await _apiClient.patch(
      '/cards/$id',
      authenticated: true,
      body: body,
    );
    return BusinessCard.fromJson(response);
  }

  Future<BusinessCard> updateCardTheme(
    String id,
    CardThemeSettings theme,
  ) async {
    final response = await _apiClient.patch(
      '/cards/$id/theme',
      authenticated: true,
      body: {'theme': theme.toJson()},
    );
    return BusinessCard.fromJson(response);
  }

  Future<void> syncSocialLinks(
    String cardId,
    List<Map<String, dynamic>> links,
  ) async {
    await _apiClient.put(
      '/cards/$cardId/social-links',
      authenticated: true,
      body: {'links': links},
    );
  }

  Future<List<CardSocialLink>> fetchSocialLinks(String cardId) async {
    final response = await _apiClient.getList(
      '/cards/$cardId/social-links',
      authenticated: true,
    );

    return response
        .whereType<Map>()
        .map((item) => CardSocialLink.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<CardAnalytics> fetchCardAnalytics(
    String cardId, {
    int days = 7,
    DateTime? from,
    DateTime? to,
  }) async {
    final params = <String, String>{};
    if (from != null && to != null) {
      params['from'] = from.toIso8601String();
      params['to'] = to.toIso8601String();
    } else {
      params['days'] = '$days';
    }
    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    final response = await _apiClient.get(
      '/cards/$cardId/analytics?$query',
      authenticated: true,
    );
    return CardAnalytics.fromJson(response);
  }

  Future<CardVisitorsResult> fetchCardVisitors(
    String cardId, {
    CardVisitorFilter filter = CardVisitorFilter.all,
  }) async {
    final query = filter == CardVisitorFilter.all
        ? ''
        : '?filter=${filter.apiValue}';
    final response = await _apiClient.get(
      '/cards/$cardId/visitors$query',
      authenticated: true,
    );
    return CardVisitorsResult.fromJson(response);
  }
}
