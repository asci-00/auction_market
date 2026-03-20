import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/locale_menu_action.dart';
import '../../../generated/locale_keys.g.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.login_title.tr()),
        actions: const [AppLocaleMenuAction()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton(
            onPressed: () => context.go('/home'),
            child: Text(LocaleKeys.login_google.tr()),
          ),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            child: Text(LocaleKeys.login_apple.tr()),
          ),
          OutlinedButton(
            onPressed: null,
            child: Text(LocaleKeys.login_kakao.tr()),
          ),
          OutlinedButton(
            onPressed: null,
            child: Text(LocaleKeys.login_naver.tr()),
          ),
        ],
      ),
    );
  }
}
