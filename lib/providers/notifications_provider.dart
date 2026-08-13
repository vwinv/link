import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:linkflutter/features/notifications/models/app_notification.dart';
import 'package:linkflutter/features/notifications/services/notifications_api_service.dart';

class NotificationsProvider extends ChangeNotifier {
  NotificationsProvider({required NotificationsApiService api}) : _api = api;

  final NotificationsApiService _api;

  final List<AppNotification> _items = [];
  int _unreadCount = 0;
  int _page = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasLoaded = false;
  String? _error;
  Timer? _pollTimer;
  AppNotification? _latestIncoming;
  String? _lastSeenId;
  void Function(AppNotification notification)? onIncoming;

  List<AppNotification> get items => List.unmodifiable(_items);
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasLoaded => _hasLoaded;
  bool get canLoadMore => _page < _totalPages;
  String? get error => _error;
  AppNotification? get latestIncoming => _latestIncoming;

  void startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      unawaited(_pollForNew());
    });
    unawaited(_pollForNew());
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void clearIncoming() {
    _latestIncoming = null;
    notifyListeners();
  }

  void clear() {
    stopPolling();
    _items.clear();
    _unreadCount = 0;
    _page = 1;
    _totalPages = 1;
    _isLoading = false;
    _isLoadingMore = false;
    _hasLoaded = false;
    _error = null;
    _latestIncoming = null;
    _lastSeenId = null;
    notifyListeners();
  }

  Future<void> refreshUnreadCount() async {
    try {
      _unreadCount = await _api.fetchUnreadCount();
      notifyListeners();
    } catch (_) {
      // Ignore: badge optionnel.
    }
  }

  Future<void> _pollForNew() async {
    try {
      final page = await _api.fetchMine(page: 1, limit: 1);
      _unreadCount = page.unreadCount;
      final newest = page.data.isEmpty ? null : page.data.first;
      if (newest != null) {
        if (_lastSeenId == null) {
          _lastSeenId = newest.id;
        } else if (newest.id != _lastSeenId) {
          _lastSeenId = newest.id;
          if (!newest.isRead) {
            _latestIncoming = newest;
            onIncoming?.call(newest);
          }
        }
      }
      notifyListeners();
    } catch (_) {
      // Ignore polling errors.
    }
  }

  Future<void> load({bool force = false}) async {
    if (_isLoading) return;
    if (_hasLoaded && !force) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final page = await _api.fetchMine(page: 1);
      _items
        ..clear()
        ..addAll(page.data);
      _unreadCount = page.unreadCount;
      _page = page.page;
      _totalPages = page.totalPages;
      _hasLoaded = true;
    } catch (_) {
      _error = 'load_failed';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !canLoadMore) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final next = await _api.fetchMine(page: _page + 1);
      _items.addAll(next.data);
      _unreadCount = next.unreadCount;
      _page = next.page;
      _totalPages = next.totalPages;
    } catch (_) {
      // Ignore pagination errors.
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> markRead(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) return;
    final current = _items[index];
    if (current.isRead) return;

    _items[index] = current.copyWith(isRead: true, readAt: DateTime.now());
    if (_unreadCount > 0) _unreadCount -= 1;
    notifyListeners();

    try {
      await _api.markRead(id);
    } catch (_) {
      _items[index] = current;
      _unreadCount += 1;
      notifyListeners();
    }
  }

  Future<void> markAllRead() async {
    final previous = List<AppNotification>.from(_items);
    final previousUnread = _unreadCount;
    _items
      ..clear()
      ..addAll(
        previous.map(
          (item) => item.isRead
              ? item
              : item.copyWith(isRead: true, readAt: DateTime.now()),
        ),
      );
    _unreadCount = 0;
    notifyListeners();

    try {
      await _api.markAllRead();
    } catch (_) {
      _items
        ..clear()
        ..addAll(previous);
      _unreadCount = previousUnread;
      notifyListeners();
    }
  }
}
