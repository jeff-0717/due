import 'package:due/models/review_start.dart';
import 'package:due/pages/settings_page.dart';
import 'package:due/providers/countdown_provider.dart';
import 'package:due/providers/hive_provider.dart';
import 'package:due/providers/review_start_provider.dart';
import 'package:due/providers/widget_config_provider.dart';
import 'package:due/repositories/countdown_repository.dart';
import 'package:due/repositories/review_start_repository.dart';
import 'package:due/repositories/widget_config_repository.dart';
import 'package:due/services/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('settings shows about dialog', (tester) async {
    final fakes = _SettingsFakes();
    await tester.pumpWidget(_buildSettings(fakes));

    await tester.tap(find.text('关于 Due'));
    await tester.pumpAndSettle();

    expect(find.text('Due'), findsWidgets);
    expect(find.text('一款极简考试倒计时应用。'), findsOneWidget);
  });

  testWidgets('settings clears data and refreshes visible state',
      (tester) async {
    final fakes = _SettingsFakes.withReviewStart();
    await tester.pumpWidget(_buildSettings(fakes));

    expect(find.text('Not set'), findsNothing);

    await tester.tap(find.text('清空全部数据').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('清空').last);
    await tester.pumpAndSettle();

    expect(fakes.hive.clearAllCalled, isTrue);
    expect(find.text('未设置'), findsOneWidget);
    expect(find.text('数据已清空'), findsOneWidget);
  });
}

Widget _buildSettings(_SettingsFakes fakes) {
  final router = GoRouter(
    initialLocation: '/settings',
    routes: [
      GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
      GoRoute(
        path: '/review-start',
        builder: (_, __) => const Scaffold(body: Text('Review route')),
      ),
      GoRoute(
        path: '/widget-preview',
        builder: (_, __) => const Scaffold(body: Text('Widget route')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      hiveServiceProvider.overrideWithValue(fakes.hive),
      countdownRepositoryProvider.overrideWithValue(fakes.countdowns),
      reviewStartRepositoryProvider.overrideWithValue(fakes.reviewStart),
      widgetConfigRepositoryProvider.overrideWithValue(fakes.widgetConfig),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

class _SettingsFakes {
  _SettingsFakes() : hive = _FakeHiveService();

  _SettingsFakes.withReviewStart()
      : hive = _FakeHiveService(),
        reviewStart = _FakeReviewStartRepository.withItem() {
    hive.onClear =
        () => (reviewStart as _FakeReviewStartRepository).item = null;
  }

  final _FakeHiveService hive;
  final CountdownRepository countdowns = _FakeCountdownRepository();
  ReviewStartRepository reviewStart = _FakeReviewStartRepository();
  final WidgetConfigRepository widgetConfig = _FakeWidgetConfigRepository();
}

class _FakeHiveService extends HiveService {
  bool clearAllCalled = false;
  VoidCallback? onClear;

  @override
  Future<void> clearAll() async {
    clearAllCalled = true;
    onClear?.call();
  }
}

class _FakeCountdownRepository extends CountdownRepository {
  _FakeCountdownRepository() : super(HiveService());
}

class _FakeReviewStartRepository extends ReviewStartRepository {
  _FakeReviewStartRepository() : super(HiveService());

  _FakeReviewStartRepository.withItem()
      : item = ReviewStart(
          id: 'default',
          startDate: DateTime.now().subtract(const Duration(days: 5)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        super(HiveService());

  ReviewStart? item;

  @override
  ReviewStart? get() => item;
}

class _FakeWidgetConfigRepository extends WidgetConfigRepository {
  _FakeWidgetConfigRepository() : super(HiveService());
}
