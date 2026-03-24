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

String formatRelativeCountdown(BuildContext context, Duration remaining) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final totalSeconds = remaining.inSeconds;
  if (totalSeconds <= 0) {
    return locale.startsWith('ko') ? '마감' : 'Closed';
  }

  if (totalSeconds < 60) {
    return locale.startsWith('ko') ? '1분 미만 남음' : 'under 1m left';
  }

  final totalMinutes = remaining.inMinutes;
  if (totalMinutes < 60) {
    return locale.startsWith('ko')
        ? '$totalMinutes분 남음'
        : '${totalMinutes}m left';
  }

  final totalHours = remaining.inHours;
  final minutes = totalMinutes.remainder(60);
  if (totalHours < 24) {
    return locale.startsWith('ko')
        ? '$totalHours시간 $minutes분 남음'
        : '${totalHours}h ${minutes}m left';
  }

  final days = remaining.inDays;
  final hours = totalHours.remainder(24);
  return locale.startsWith('ko')
      ? '$days일 $hours시간 남음'
      : '${days}d ${hours}h left';
}
