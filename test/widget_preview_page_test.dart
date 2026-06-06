import 'package:due/models/countdown.dart';
import 'package:due/models/widget_config.dart';
import 'package:due/pages/widget_preview_page.dart';
import 'package:due/providers/countdown_provider.dart';
import 'package:due/providers/widget_config_provider.dart';
import 'package:due/providers/widget_sync_provider.dart';
import 'package:due/repositories/countdown_repository.dart';
import 'package:due/repositories/widget_config_repository.dart';
import 'package:due/services/hive_service.dart';
import 'package:due/services/widget_sync_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('widget preview shows empty state with disabled sync',
      (tester) async {
    await tester.pumpWidget(_buildWidgetPreview(_WidgetPreviewFakes()));

    expect(find.text('No countdowns available'), findsOneWidget);
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
        isFalse);
  });

  testWidgets('widget preview selects countdown and syncs selected item',
      (tester) async {
    final countdown = _countdown(id: 'exam', title: 'Final Exam');
    final fakes = _WidgetPreviewFakes(countdowns: [countdown]);
    await tester.pumpWidget(_buildWidgetPreview(fakes));

    await tester.tap(find.text('Final Exam').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sync to Widget'));
    await tester.pumpAndSettle();

    expect(fakes.config.item?.countdownId, 'exam');
    expect(fakes.sync.synced.single.id, 'exam');
    expect(find.text('Synced to widget'), findsOneWidget);
  });
}

Widget _buildWidgetPreview(_WidgetPreviewFakes fakes) {
  return ProviderScope(
    overrides: [
      countdownRepositoryProvider.overrideWithValue(fakes.countdowns),
      widgetConfigRepositoryProvider.overrideWithValue(fakes.config),
      widgetSyncServiceProvider.overrideWithValue(fakes.sync),
    ],
    child: const MaterialApp(home: WidgetPreviewPage()),
  );
}

Countdown _countdown({required String id, required String title}) {
  final now = DateTime.now();
  return Countdown(
    id: id,
    title: title,
    targetDate: now.add(const Duration(days: 15)),
    repeatType: RepeatType.once,
    color: '#2563EB',
    icon: 'E',
    createdAt: now,
    updatedAt: now,
  );
}

class _WidgetPreviewFakes {
  _WidgetPreviewFakes({List<Countdown> countdowns = const []})
      : countdowns = _FakeCountdownRepository(countdowns);

  final _FakeCountdownRepository countdowns;
  final _FakeWidgetConfigRepository config = _FakeWidgetConfigRepository();
  final _FakeWidgetSyncService sync = _FakeWidgetSyncService();
}

class _FakeCountdownRepository extends CountdownRepository {
  _FakeCountdownRepository(this.items) : super(HiveService());

  final List<Countdown> items;

  @override
  List<Countdown> getAll() => items;
}

class _FakeWidgetConfigRepository extends WidgetConfigRepository {
  _FakeWidgetConfigRepository() : super(HiveService());

  WidgetConfig? item;

  @override
  WidgetConfig? get() => item;

  @override
  Future<WidgetConfig> set(String countdownId, String style) async {
    item = WidgetConfig(
      id: 'default',
      countdownId: countdownId,
      style: style,
      updatedAt: DateTime.now(),
    );
    return item!;
  }
}

class _FakeWidgetSyncService extends WidgetSyncService {
  final List<Countdown> synced = [];

  @override
  Future<void> syncCountdown(Countdown countdown) async {
    synced.add(countdown);
  }
}
