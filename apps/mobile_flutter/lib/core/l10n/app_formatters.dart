import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_localization.dart';

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

String formatRelativeCountdown(BuildContext context, Duration remaining) {
  final l10n = context.l10n;
  final totalSeconds = remaining.inSeconds;
  if (totalSeconds <= 0) {
    return l10n.genericCountdownExpired;
  }

  if (totalSeconds < 60) {
    return l10n.genericCountdownLessThanMinute;
  }

  final totalMinutes = remaining.inMinutes;
  if (totalMinutes < 60) {
    return l10n.genericCountdownMinutesRemaining(totalMinutes);
  }

  final totalHours = remaining.inHours;
  final minutes = totalMinutes.remainder(60);
  if (totalHours < 24) {
    return l10n.genericCountdownHoursRemaining(totalHours, minutes);
  }

  final days = remaining.inDays;
  final hours = totalHours.remainder(24);
  return l10n.genericCountdownDaysRemaining(days, hours);
}
