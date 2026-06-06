import 'package:due/models/monitor_hit.dart';
import 'package:due/repositories/monitor_repository.dart';
import 'package:due/services/monitor_background_service.dart';
import 'package:due/services/monitor_notification_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('background bridge enforces explicit low-frequency schedule', () async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(MonitorBackgroundService.channel,
            (call) async {
      calls.add(call);
      return null;
    });

    await const MonitorBackgroundService().configurePeriodicChecks(hours: 8);

    expect(calls.single.method, 'configurePeriodicChecks');
    expect(calls.single.arguments, {'hours': 8});
  });

  test('notification service sends only unsent hits once', () async {
    final repository = MonitorRepository(null);
    final now = DateTime(2026, 6, 6, 9);
    await repository.saveHit(_hit('hit-1', now, notificationSentAt: null));
    await repository.saveHit(_hit('hit-2', now, notificationSentAt: now));

    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(MonitorNotificationService.channel,
            (call) async {
      calls.add(call);
      return null;
    });

    final sent = await MonitorNotificationService(repository).notifyNewHits();

    expect(sent, 1);
    expect(calls.single.method, 'showMonitorHit');
    expect(calls.single.arguments['title'], 'Exam notice hit-1');
    expect(repository.getAllHits().where((hit) => hit.notificationSentAt == null),
        isEmpty);
  });
}

MonitorHit _hit(
  String id,
  DateTime now, {
  required DateTime? notificationSentAt,
}) {
  return MonitorHit(
    id: id,
    sourceId: 'source-1',
    title: 'Exam notice $id',
    link: 'https://example.edu/$id',
    summary: 'Exam update',
    matchedKeywords: const ['exam'],
    publishedAt: now,
    discoveredAt: now,
    contentFingerprint: 'source-1|$id',
    notificationSentAt: notificationSentAt,
    createdAt: now,
  );
}
