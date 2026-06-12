import 'package:due/models/countdown.dart';
import 'package:due/models/review_start.dart';
import 'package:due/pages/home_page.dart';
import 'package:due/providers/countdown_provider.dart';
import 'package:due/providers/home_config_provider.dart';
import 'package:due/providers/review_start_provider.dart';
import 'package:due/repositories/countdown_repository.dart';
import 'package:due/repositories/home_config_repository.dart';
import 'package:due/repositories/review_start_repository.dart';
import 'package:due/services/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('home redesign focuses on date countdowns without task records',
      (tester) async {
    await tester.pumpWidget(_buildHome(countdowns: const []));

    expect(find.text('备考日程'), findsOneWidget);
    expect(find.text('Keep your focus. Stay calm.'), findsOneWidget);
    expect(find.byKey(const Key('home_hero_countdown')), findsOneWidget);
    expect(find.byKey(const Key('home_review_days_card')), findsNothing);
    expect(find.byKey(const Key('home_countdown_count_card')), findsOneWidget);
    expect(find.text('今日专注'), findsNothing);
    expect(find.text('今日任务'), findsNothing);
    await tester.drag(find.byType(ListView), const Offset(0, -520));
    await tester.pump();

    expect(find.byKey(const Key('home_countdown_section')), findsOneWidget);
    expect(find.text('暂无倒计时'), findsOneWidget);
    expect(find.text('添加重要日期'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('Add route'), findsOneWidget);
  });

  testWidgets('home highlights nearest countdown and keeps list sorted',
      (tester) async {
    final now = DateTime.now();
    final later = _countdown(
      id: 'later',
      title: 'Later Exam',
      targetDate: now.add(const Duration(days: 40)),
    );
    final soon = _countdown(
      id: 'soon',
      title: 'Soon Exam',
      targetDate: now.add(const Duration(days: 10)),
    );

    await tester.pumpWidget(_buildHome(countdowns: [later, soon]));

    expect(find.text('距离目标考试还有'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -520));
    await tester.pump();

    expect(find.text('全部倒计时'), findsOneWidget);
    expect(find.textContaining('Soon Exam'), findsWidgets);

    final soonTop = tester.getTopLeft(find.text('Soon Exam').last).dy;
    final laterTop = tester.getTopLeft(find.text('Later Exam')).dy;
    expect(soonTop, lessThan(laterTop));
  });

  testWidgets('home can choose which countdown appears in hero',
      (tester) async {
    final now = DateTime.now();
    final later = _countdown(
      id: 'later',
      title: 'Later Exam',
      targetDate: now.add(const Duration(days: 40)),
    );
    final soon = _countdown(
      id: 'soon',
      title: 'Soon Exam',
      targetDate: now.add(const Duration(days: 10)),
    );
    final homeConfig = _FakeHomeConfigRepository();

    await tester.pumpWidget(
      _buildHome(
        countdowns: [later, soon],
        homeConfig: homeConfig,
      ),
    );

    expect(find.textContaining('Soon Exam'), findsWidgets);

    await tester.tap(find.byKey(const Key('home_select_hero_countdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home_select_countdown_later')));
    await tester.pumpAndSettle();

    expect(homeConfig.selectedCountdownId, 'later');
    expect(find.textContaining('Later Exam'), findsWidgets);
  });

  testWidgets('home falls back when selected countdown no longer exists',
      (tester) async {
    final now = DateTime.now();
    final soon = _countdown(
      id: 'soon',
      title: 'Soon Exam',
      targetDate: now.add(const Duration(days: 10)),
    );
    final homeConfig = _FakeHomeConfigRepository('deleted');

    await tester.pumpWidget(
      _buildHome(countdowns: [soon], homeConfig: homeConfig),
    );

    expect(find.textContaining('Soon Exam'), findsWidgets);
    expect(find.byKey(const Key('home_hero_countdown')), findsOneWidget);
  });

  testWidgets('home moves expired countdowns last and strikes them through',
      (tester) async {
    final now = DateTime.now();
    final expired = _countdown(
      id: 'expired',
      title: 'Expired Exam',
      targetDate: now.subtract(const Duration(days: 2)),
    );
    final active = _countdown(
      id: 'active',
      title: 'Active Exam',
      targetDate: now.add(const Duration(days: 12)),
    );

    await tester.pumpWidget(_buildHome(countdowns: [expired, active]));
    await tester.drag(find.byType(ListView), const Offset(0, -520));
    await tester.pump();

    final activeTop = tester.getTopLeft(find.text('Active Exam').last).dy;
    final expiredTop = tester.getTopLeft(find.text('Expired Exam')).dy;
    expect(activeTop, lessThan(expiredTop));

    final expiredText = tester.widget<Text>(find.text('Expired Exam'));
    expect(expiredText.style?.decoration, TextDecoration.lineThrough);
  });

  testWidgets('home shows review days even when countdown list is empty',
      (tester) async {
    final now = DateTime.now();
    final reviewStart = ReviewStart(
      id: 'default',
      startDate: now.subtract(const Duration(days: 2)),
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(
      _buildHome(countdowns: const [], reviewStart: reviewStart),
    );

    expect(find.text('3'), findsOneWidget);
    expect(find.text('天'), findsWidgets);
    expect(find.text('已坚持复习'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -520));
    await tester.pump();

    expect(find.text('暂无倒计时'), findsOneWidget);
  });

  testWidgets('review summary only shows review days', (tester) async {
    final now = DateTime.now();
    final reviewStart = ReviewStart(
      id: 'default',
      startDate: now.subtract(const Duration(days: 4)),
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(
      _buildHome(
        countdowns: [
          _countdown(
            id: 'exam',
            title: 'Exam',
            targetDate: now.add(const Duration(days: 30)),
          ),
        ],
        reviewStart: reviewStart,
      ),
    );

    expect(find.text('复习统计'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('已坚持复习'), findsOneWidget);
    expect(find.textContaining('个倒计时'), findsNothing);
  });

  testWidgets('home monitor action opens monitor', (tester) async {
    await tester.pumpWidget(_buildHome(countdowns: const []));

    await tester.tap(find.byKey(const Key('home_open_monitor')));
    await tester.pumpAndSettle();
    expect(find.text('Monitor route'), findsOneWidget);
  });

  testWidgets('home settings action opens settings', (tester) async {
    await tester.pumpWidget(_buildHome(countdowns: const []));

    await tester.tap(find.byKey(const Key('home_open_settings')));
    await tester.pumpAndSettle();
    expect(find.text('Settings route'), findsOneWidget);
  });

  testWidgets('home fits the provided mobile reference viewport',
      (tester) async {
    tester.view.physicalSize = const Size(390, 933);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.now();
    await tester.pumpWidget(
      _buildHome(
        countdowns: [
          _countdown(
            id: 'exam',
            title: '目标考试',
            targetDate: now.add(const Duration(days: 84)),
          ),
        ],
      ),
    );

    expect(find.byKey(const Key('home_hero_countdown')), findsOneWidget);
    expect(find.text('今日专注'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

Widget _buildHome({
  required List<Countdown> countdowns,
  ReviewStart? reviewStart,
  HomeConfigRepository? homeConfig,
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HomePage()),
      GoRoute(
        path: '/add',
        builder: (_, __) => const Scaffold(body: Text('Add route')),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const Scaffold(body: Text('Settings route')),
      ),
      GoRoute(
        path: '/monitor',
        builder: (_, __) => const Scaffold(body: Text('Monitor route')),
      ),
      GoRoute(
        path: '/edit/:id',
        builder: (_, state) => Scaffold(
          body: Text('Edit ${state.pathParameters['id']}'),
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      countdownRepositoryProvider.overrideWithValue(
        _FakeCountdownRepository(countdowns),
      ),
      reviewStartRepositoryProvider.overrideWithValue(
        _FakeReviewStartRepository(reviewStart),
      ),
      homeConfigRepositoryProvider.overrideWithValue(
        homeConfig ?? _FakeHomeConfigRepository(),
      ),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

Countdown _countdown({
  required String id,
  required String title,
  required DateTime targetDate,
}) {
  final now = DateTime.now();
  return Countdown(
    id: id,
    title: title,
    targetDate: targetDate,
    repeatType: RepeatType.once,
    color: '#2563EB',
    icon: 'E',
    createdAt: now,
    updatedAt: now,
  );
}

class _FakeCountdownRepository extends CountdownRepository {
  _FakeCountdownRepository(this.items) : super(HiveService());

  final List<Countdown> items;

  @override
  List<Countdown> getAll() => items;
}

class _FakeReviewStartRepository extends ReviewStartRepository {
  _FakeReviewStartRepository(this.item) : super(HiveService());

  final ReviewStart? item;

  @override
  ReviewStart? get() => item;
}

class _FakeHomeConfigRepository extends HomeConfigRepository {
  _FakeHomeConfigRepository([this.selectedCountdownId]) : super(HiveService());

  String? selectedCountdownId;

  @override
  String? getSelectedCountdownId() => selectedCountdownId;

  @override
  Future<void> saveSelectedCountdownId(String? countdownId) async {
    selectedCountdownId = countdownId;
  }
}
