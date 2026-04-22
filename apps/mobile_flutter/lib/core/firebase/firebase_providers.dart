import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_bootstrap.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  ref.watch(appBootstrapProvider).requireValue;
  return FirebaseAuth.instance;
});

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  ref.watch(appBootstrapProvider).requireValue;
  return FirebaseStorage.instance;
});

final firebaseMessagingProvider = Provider<FirebaseMessaging>((ref) {
  ref.watch(appBootstrapProvider).requireValue;
  return FirebaseMessaging.instance;
});
