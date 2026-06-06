import 'package:due/models/countdown.dart';
import 'package:due/models/review_start.dart';
import 'package:due/pages/home_page.dart';
import 'package:due/providers/countdown_provider.dart';
import 'package:due/providers/review_start_provider.dart';
import 'package:due/repositories/countdown_repository.dart';
import 'package:due/repositories/review_start_repository.dart';
import 'package:due/services/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('home empty state keeps add and settings routes available',
      (tester) async {
    await tester.pumpWidget(_buildHome(countdowns: const []));

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

    expect(find.text('最近事项'), findsOneWidget);
    expect(find.text('Soon Exam'), findsWidgets);
    expect(find.text('按最近日期排序'), findsOneWidget);

    final soonTop = tester.getTopLeft(find.text('Soon Exam').last).dy;
    final laterTop = tester.getTopLeft(find.text('Later Exam')).dy;
    expect(soonTop, lessThan(laterTop));
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

    expect(find.textContaining('已复习 3 天'), findsOneWidget);
    expect(find.text('暂无倒计时'), findsOneWidget);
  });
}

Widget _buildHome({
  required List<Countdown> countdowns,
  ReviewStart? reviewStart,
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
