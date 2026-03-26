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
    final data = document.data();

    return NotificationItem(
      id: document.id,
      title: (data['title'] as String?) ?? '',
      body: (data['body'] as String?) ?? '',
      deeplink: data['deeplink'] as String?,
      isRead: data['isRead'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
