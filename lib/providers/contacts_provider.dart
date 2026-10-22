import 'package:flutter/foundation.dart';
import 'package:linkflutter/features/contacts/models/link_contact.dart';
import 'package:linkflutter/features/contacts/services/contacts_api_service.dart';

class ContactsProvider extends ChangeNotifier {
  ContactsProvider({required ContactsApiService contactsApi})
      : _contactsApi = contactsApi;

  final ContactsApiService _contactsApi;

  List<LinkContact> _contacts = [];
  bool _isLoading = false;
  bool _hasLoaded = false;

  List<LinkContact> get contacts => List.unmodifiable(_contacts);
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;

  List<LinkContact> get exchangeContacts => _contacts
      .where((contact) => contact.source == ContactSource.exchange)
      .toList();

  List<LinkContact> get scannedContacts => _contacts
      .where((contact) => contact.source == ContactSource.aiScan)
      .toList();

  List<LinkContact> get recentContacts =>
      _contacts.take(5).toList(growable: false);

  Future<void>? _ongoingLoad;
  int _loadGeneration = 0;

  Future<void> load() async {
    if (_ongoingLoad != null) return _ongoingLoad!;

    _ongoingLoad = _performLoad();
    try {
      await _ongoingLoad;
    } finally {
      _ongoingLoad = null;
    }
  }

  Future<void> _performLoad() async {
    final generation = ++_loadGeneration;
    _isLoading = true;
    notifyListeners();

    try {
      final fetched = await _contactsApi.fetchContacts();
      if (generation != _loadGeneration) return;
      _contacts = fetched;
    } catch (_) {
      if (generation != _loadGeneration) return;
      if (!_hasLoaded) {
        _contacts = [];
      }
    }

    if (generation != _loadGeneration) return;
    _hasLoaded = true;
    _isLoading = false;
    notifyListeners();
  }

  void reset() {
    _contacts = [];
    _isLoading = false;
    _hasLoaded = false;
    _ongoingLoad = null;
    _loadGeneration++;
    notifyListeners();
  }

  void _upsertContact(LinkContact contact) {
    final index = _contacts.indexWhere((item) => item.id == contact.id);
    if (index >= 0) {
      _contacts[index] = contact;
    } else {
      _contacts.insert(0, contact);
    }
  }

  Future<LinkContact> exchangeFromCardSlug(String cardSlug) async {
    if (_ongoingLoad != null) {
      await _ongoingLoad;
    }

    final contact = await _contactsApi.exchangeFromCardSlug(cardSlug);
    _upsertContact(contact);
    _hasLoaded = true;
    _loadGeneration++;
    notifyListeners();

    await load();
    return _contacts.firstWhere(
      (item) => item.id == contact.id,
      orElse: () => contact,
    );
  }
}
