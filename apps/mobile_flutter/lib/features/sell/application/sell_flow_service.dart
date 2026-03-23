import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../data/sell_draft_form_data.dart';

final sellFlowServiceProvider = Provider<SellFlowService>((ref) {
  return SellFlowService(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
    functions: ref.watch(functionsProvider),
    storage: ref.watch(firebaseStorageProvider),
  );
});

class SellFlowService {
  const SellFlowService({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required FirebaseFunctions functions,
    required FirebaseStorage storage,
  })  : _auth = auth,
        _firestore = firestore,
        _functions = functions,
        _storage = storage;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final FirebaseStorage _storage;

  Future<SellDraftSaveResult> saveDraft(
    SellDraftFormData form, {
    required List<XFile> newImageFiles,
    required List<XFile> newAuthImageFiles,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw FirebaseFunctionsException(
        code: 'unauthenticated',
        message: 'Sign-in is required to save a draft.',
      );
    }

    final itemId = form.itemId ?? _firestore.collection('items').doc().id;
    final uploadedImageUrls = await _uploadImages(
      uid: uid,
      itemId: itemId,
      files: newImageFiles,
      scope: _SellUploadScope.gallery,
    );
    final uploadedAuthImageUrls = await _uploadImages(
      uid: uid,
      itemId: itemId,
      files: newAuthImageFiles,
      scope: _SellUploadScope.auth,
    );

    final imageUrls = [...form.existingImageUrls, ...uploadedImageUrls];
    final authImageUrls = [
      ...form.existingAuthImageUrls,
      ...uploadedAuthImageUrls,
    ];

    await _functions.httpsCallable('createOrUpdateItem').call<void>({
      'id': itemId,
      'status': 'DRAFT',
      'categoryMain': form.categoryMain,
      'categorySub': form.categorySub,
      'title': form.title,
      'description': form.description,
      'condition': form.condition,
      'tags': form.tags,
      'imageUrls': imageUrls,
      'authImageUrls': authImageUrls,
      'draftAuction': {
        'startPrice': form.startPrice,
        'buyNowPrice': form.buyNowPrice,
        'durationDays': form.durationDays,
      },
      'appraisal': {
        'status': form.appraisalRequested ? 'REQUESTED' : 'NONE',
      },
    });

    return SellDraftSaveResult(
      itemId: itemId,
      imageUrls: imageUrls,
      authImageUrls: authImageUrls,
    );
  }

  Future<String> publishAuction(
    SellDraftFormData form, {
    required List<XFile> newImageFiles,
    required List<XFile> newAuthImageFiles,
  }) async {
    final savedDraft = await saveDraft(
      form,
      newImageFiles: newImageFiles,
      newAuthImageFiles: newAuthImageFiles,
    );

    final now = DateTime.now();
    final endAt = now.add(Duration(days: form.durationDays));
    final result =
        await _functions.httpsCallable('createAuctionFromItem').call<dynamic>({
      'itemId': savedDraft.itemId,
      'startAt': now.toIso8601String(),
      'endAt': endAt.toIso8601String(),
      'startPrice': form.startPrice,
      'buyNowPrice': form.buyNowPrice,
    });

    if (result.data case final Map<dynamic, dynamic> data) {
      final auctionId = data['auctionId'];
      if (auctionId is String && auctionId.isNotEmpty) {
        return auctionId;
      }
    }

    throw FirebaseFunctionsException(
      code: 'unknown',
      message: 'Auction publish did not return an auction id.',
    );
  }

  Future<List<String>> _uploadImages({
    required String uid,
    required String itemId,
    required List<XFile> files,
    required _SellUploadScope scope,
  }) async {
    final urls = <String>[];

    for (var index = 0; index < files.length; index++) {
      final file = files[index];
      final bytes = await file.readAsBytes();
      final storagePath = scope == _SellUploadScope.gallery
          ? 'users/$uid/items/$itemId/gallery/${DateTime.now().millisecondsSinceEpoch}_$index.${_fileExtension(file.name)}'
          : 'users/$uid/auth/$itemId/${DateTime.now().millisecondsSinceEpoch}_$index.${_fileExtension(file.name)}';

      final reference = _storage.ref(storagePath);
      await reference.putData(
        bytes,
        SettableMetadata(contentType: _contentTypeFor(file.name, bytes)),
      );
      urls.add(await reference.getDownloadURL());
    }

    return urls;
  }
}

class SellDraftSaveResult {
  const SellDraftSaveResult({
    required this.itemId,
    required this.imageUrls,
    required this.authImageUrls,
  });

  final String itemId;
  final List<String> imageUrls;
  final List<String> authImageUrls;
}

enum _SellUploadScope {
  gallery,
  auth,
}

String _fileExtension(String name) {
  final segments = name.split('.');
  if (segments.length < 2) {
    return 'jpg';
  }
  return segments.last.toLowerCase();
}

String _contentTypeFor(String name, Uint8List bytes) {
  final extension = _fileExtension(name);
  switch (extension) {
    case 'png':
      return 'image/png';
    case 'webp':
      return 'image/webp';
    case 'gif':
      return 'image/gif';
    default:
      return 'image/jpeg';
  }
}
