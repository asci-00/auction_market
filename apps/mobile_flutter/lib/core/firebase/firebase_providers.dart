import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_bootstrap.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  ref.watch(appBootstrapProvider).requireValue;
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  ref.watch(appBootstrapProvider).requireValue;
  return FirebaseFirestore.instance;
});

final functionsProvider = Provider<FirebaseFunctions>((ref) {
  ref.watch(appBootstrapProvider).requireValue;
  return FirebaseFunctions.instance;
});

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  ref.watch(appBootstrapProvider).requireValue;
  return FirebaseStorage.instance;
});

final firebaseMessagingProvider = Provider<FirebaseMessaging>((ref) {
  ref.watch(appBootstrapProvider).requireValue;
  return FirebaseMessaging.instance;
});
