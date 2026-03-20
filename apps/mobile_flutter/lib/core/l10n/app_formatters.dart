import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatKrw(BuildContext context, num amount) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return NumberFormat.currency(
    locale: locale,
    symbol: '₩',
    decimalDigits: 0,
  ).format(amount);
}

String formatCompactDateTime(BuildContext context, DateTime dateTime) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final pattern = locale.startsWith('ko') ? 'M.d HH:mm' : 'MMM d, HH:mm';
  return DateFormat(pattern, locale).format(dateTime);
}
