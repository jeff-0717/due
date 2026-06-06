import 'package:due/models/countdown.dart';
import 'package:due/services/widget_sync_service.dart';
import 'package:due/utils/app_date_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildCountdownData matches Android widget keys', () {
    final countdown = _countdown();
    final data = WidgetSyncService.buildCountdownData(countdown);

    expect(data['title'], 'Final Exam');
    expect(
        data['daysLeft'],
        AppDateUtils.daysUntil(
          countdown.targetDate,
          countdown.repeatType,
        ));
    expect(data['targetDate'], isA<String>());
    expect(data['color'], '#2563EB');
    expect(data['icon'], 'E');
  });
}

Countdown _countdown() {
  final now = DateTime.now();
  return Countdown(
    id: 'exam',
    title: 'Final Exam',
    targetDate: now.add(const Duration(days: 12)),
    repeatType: RepeatType.once,
    color: '#2563EB',
    icon: 'E',
    createdAt: now,
    updatedAt: now,
  );
}
