import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final rootScaffoldMessengerKeyProvider =
    Provider<GlobalKey<ScaffoldMessengerState>>((ref) {
      return GlobalKey<ScaffoldMessengerState>(
        debugLabel: 'rootScaffoldMessenger',
      );
    });
