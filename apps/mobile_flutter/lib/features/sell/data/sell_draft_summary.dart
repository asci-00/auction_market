import 'package:cloud_firestore/cloud_firestore.dart';

class SellDraftSummary {
  const SellDraftSummary({
    required this.id,
    required this.status,
    required this.categoryMain,
    required this.categorySub,
    required this.title,
    required this.description,
    required this.condition,
    required this.tags,
    required this.imageUrls,
    required this.authImageUrls,
    required this.appraisalRequested,
    required this.startPrice,
    required this.buyNowPrice,
    required this.durationDays,
    required this.updatedAt,
  });

  final String id;
  final String status;
  final String categoryMain;
  final String categorySub;
  final String title;
  final String description;
  final String condition;
  final List<String> tags;
  final List<String> imageUrls;
  final List<String> authImageUrls;
  final bool appraisalRequested;
  final int? startPrice;
  final int? buyNowPrice;
  final int durationDays;
  final DateTime? updatedAt;

  factory SellDraftSummary.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return SellDraftSummary.fromMap({'id': document.id, ...document.data()});
  }

  factory SellDraftSummary.fromMap(Map<String, dynamic> data) {
    final appraisal = (data['appraisal'] as Map<String, dynamic>?) ?? const {};
    final draftAuction =
        (data['draftAuction'] as Map<String, dynamic>?) ?? const {};

    return SellDraftSummary(
      id: data['id'] as String? ?? '',
      status: (data['status'] as String?) ?? 'DRAFT',
      categoryMain: (data['categoryMain'] as String?) ?? 'GOODS',
      categorySub: (data['categorySub'] as String?) ?? '',
      title: (data['title'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      condition: (data['condition'] as String?) ?? '',
      tags: ((data['tags'] as List<dynamic>?) ?? const [])
          .whereType<String>()
          .toList(),
      imageUrls: ((data['imageUrls'] as List<dynamic>?) ?? const [])
          .whereType<String>()
          .toList(),
      authImageUrls: ((data['authImageUrls'] as List<dynamic>?) ?? const [])
          .whereType<String>()
          .toList(),
      appraisalRequested: (appraisal['status'] as String?) == 'REQUESTED',
      startPrice: (draftAuction['startPrice'] as num?)?.toInt(),
      buyNowPrice: (draftAuction['buyNowPrice'] as num?)?.toInt(),
      durationDays: (draftAuction['durationDays'] as num?)?.toInt() ?? 3,
      updatedAt: _dateTimeFromPayload(data['updatedAt']),
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
