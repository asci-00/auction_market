import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.deeplink,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String? deeplink;
  final bool isRead;
  final DateTime? createdAt;

  factory NotificationItem.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return NotificationItem.fromMap({'id': document.id, ...document.data()});
  }

  factory NotificationItem.fromMap(Map<String, dynamic> data) {
    return NotificationItem(
      id: data['id'] as String? ?? '',
      title: (data['title'] as String?) ?? '',
      body: (data['body'] as String?) ?? '',
      deeplink: data['deeplink'] as String?,
      isRead: data['isRead'] as bool? ?? false,
      createdAt: _dateTimeFromPayload(data['createdAt']),
    );
  }
}

DateTime? _dateTimeFromPayload(Object? value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  }
  return null;
}
