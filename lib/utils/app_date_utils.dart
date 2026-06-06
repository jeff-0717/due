import 'package:intl/intl.dart';
import '../models/countdown.dart';

class AppDateUtils {
  AppDateUtils._();

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static int daysUntil(DateTime target, RepeatType repeatType) {
    final today = _today();
    final targetDate = DateTime(target.year, target.month, target.day);

    switch (repeatType) {
      case RepeatType.once:
        return targetDate.difference(today).inDays;
      case RepeatType.yearly:
        final thisYear = DateTime(today.year, target.month, target.day);
        if (!thisYear.isBefore(today)) {
          return thisYear.difference(today).inDays;
        }
        final nextYear = DateTime(today.year + 1, target.month, target.day);
        return nextYear.difference(today).inDays;
    }
  }

  static int reviewDaysSince(DateTime startDate) {
    final today = _today();
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final diff = today.difference(start).inDays;
    return diff < 0 ? 0 : diff + 1;
  }

  static String formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd').format(date);
  }

  static DateTime resolveNextTargetDate(
      DateTime target, RepeatType repeatType) {
    final today = _today();
    final targetDate = DateTime(target.year, target.month, target.day);

    switch (repeatType) {
      case RepeatType.once:
        return targetDate;
      case RepeatType.yearly:
        final thisYear = DateTime(today.year, target.month, target.day);
        if (!thisYear.isBefore(today)) {
          return thisYear;
        }
        return DateTime(today.year + 1, target.month, target.day);
    }
  }
}
