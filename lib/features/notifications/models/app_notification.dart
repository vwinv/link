class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    this.campaignId,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      readAt: json['readAt'] != null
          ? DateTime.tryParse(json['readAt'] as String)
          : null,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      campaignId: json['campaignId'] as String?,
    );
  }

  final String id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final String? campaignId;

  AppNotification copyWith({bool? isRead, DateTime? readAt}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt,
      campaignId: campaignId,
    );
  }
}

class NotificationsPage {
  const NotificationsPage({
    required this.data,
    required this.total,
    required this.unreadCount,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory NotificationsPage.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>? ?? const {};
    final rows = json['data'];
    final data = <AppNotification>[];
    if (rows is List) {
      for (final item in rows) {
        if (item is! Map) continue;
        data.add(
          AppNotification.fromJson(Map<String, dynamic>.from(item)),
        );
      }
    }
    return NotificationsPage(
      data: data,
      total: meta['total'] as int? ?? data.length,
      unreadCount: meta['unreadCount'] as int? ?? 0,
      page: meta['page'] as int? ?? 1,
      limit: meta['limit'] as int? ?? 30,
      totalPages: meta['totalPages'] as int? ?? 1,
    );
  }

  final List<AppNotification> data;
  final int total;
  final int unreadCount;
  final int page;
  final int limit;
  final int totalPages;
}
