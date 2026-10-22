import 'package:linkflutter/core/api/api_client.dart';
import 'package:linkflutter/features/contacts/models/link_contact.dart';

class ContactsApiService {
  ContactsApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<LinkContact>> fetchContacts() async {
    final response = await _apiClient.getList(
      '/contacts',
      authenticated: true,
    );

    return response
        .map(
          (item) => LinkContact.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<LinkContact> exchangeFromCardSlug(String cardSlug) async {
    final response = await _apiClient.post(
      '/contacts/exchange',
      authenticated: true,
      body: {'cardSlug': cardSlug},
    );

    return LinkContact.fromJson(Map<String, dynamic>.from(response));
  }
}
