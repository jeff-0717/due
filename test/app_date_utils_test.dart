import 'package:due/models/countdown.dart';
import 'package:due/utils/app_date_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reviewDaysSince returns one-based day count', () {
    final today = DateTime.now();

    expect(AppDateUtils.reviewDaysSince(today), 1);
  });

  test('resolveNextTargetDate returns a non-past yearly target', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final future = today.add(
      const Duration(days: 30),
    );

    final next = AppDateUtils.resolveNextTargetDate(future, RepeatType.yearly);

    expect(next.isBefore(today), isFalse);
    expect(next.month, future.month);
    expect(next.day, future.day);
  });
}
