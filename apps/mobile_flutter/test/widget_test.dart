import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:auction_market_mobile/core/l10n/app_localization.dart';

void main() {
  test('translation assets expose the same nested keys', () {
    final korean = _flattenKeys(_readJson('ko'));
    final english = _flattenKeys(_readJson('en'));

    expect(korean, english);
    expect(korean, contains('app.title'));
    expect(korean, contains('login.google'));
    expect(korean, contains('auction.placeBid'));
  });

  test('locale resolution follows supported language codes', () {
    expect(resolveAppLocale(const Locale('ko', 'KR')), const Locale('ko'));
    expect(resolveAppLocale(const Locale('en', 'US')), const Locale('en'));
    expect(resolveAppLocale(const Locale('ja', 'JP')), fallbackAppLocale);
    expect(resolveAppLocale(null), fallbackAppLocale);
  });
}

Map<String, dynamic> _readJson(String languageCode) {
  final file = File('assets/translations/$languageCode.json');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

Set<String> _flattenKeys(Map<String, dynamic> source, [String prefix = '']) {
  final keys = <String>{};

  source.forEach((key, value) {
    final next = prefix.isEmpty ? key : '$prefix.$key';

    if (value is Map<String, dynamic>) {
      keys.addAll(_flattenKeys(value, next));
      return;
    }

    keys.add(next);
  });

  return keys;
}
