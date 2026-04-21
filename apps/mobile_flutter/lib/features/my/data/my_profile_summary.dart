import 'package:cloud_firestore/cloud_firestore.dart';

class MyProfileSummary {
  const MyProfileSummary({
    required this.phoneVerification,
    required this.identityVerification,
    required this.sellerVerification,
  });

  final String phoneVerification;
  final String identityVerification;
  final String sellerVerification;

  factory MyProfileSummary.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return MyProfileSummary.fromMap(
      document.data() ?? const <String, dynamic>{},
    );
  }

  factory MyProfileSummary.fromMap(Map<String, dynamic> data) {
    final verification =
        (data['verification'] as Map<String, dynamic>?) ?? const {};

    return MyProfileSummary(
      phoneVerification: (verification['phone'] as String?) ?? 'UNVERIFIED',
      identityVerification: (verification['id'] as String?) ?? 'UNVERIFIED',
      sellerVerification:
          (verification['preciousSeller'] as String?) ?? 'UNVERIFIED',
    );
  }
}
