import 'package:due/models/review_start.dart';
import 'package:due/pages/review_start_page.dart';
import 'package:due/pages/settings_page.dart';
import 'package:due/providers/review_start_provider.dart';
import 'package:due/repositories/review_start_repository.dart';
import 'package:due/services/hive_service.dart';
import 'package:due/utils/app_date_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets(
      'review start page saves and falls back home when opened directly',
      (tester) async {
    final repository = _FakeReviewStartRepository();
    await tester.pumpWidget(
      _buildApp(repository, initialLocation: '/review-start'),
    );

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(repository.item, isNotNull);
    expect(find.text('Home route'), findsOneWidget);
  });

  testWidgets('settings summary updates after saving review start date',
      (tester) async {
    final repository = _FakeReviewStartRepository();
    await tester
        .pumpWidget(_buildApp(repository, initialLocation: '/settings'));

    expect(find.text('Not set'), findsOneWidget);

    await tester.tap(find.text('Review Start Date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Not set'), findsNothing);
    expect(
      find.text(AppDateUtils.formatDate(repository.item!.startDate)),
      findsOneWidget,
    );
  });
}

Widget _buildApp(
  _FakeReviewStartRepository repository, {
  required String initialLocation,
}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const Scaffold(body: Text('Home route')),
      ),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
      GoRoute(
        path: '/review-start',
        builder: (_, __) => const ReviewStartPage(),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      reviewStartRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

class _FakeReviewStartRepository extends ReviewStartRepository {
  _FakeReviewStartRepository() : super(HiveService());

  ReviewStart? item;

  @override
  ReviewStart? get() => item;

  @override
  Future<ReviewStart> set(DateTime startDate) async {
    final now = DateTime.now();
    item = ReviewStart(
      id: 'default',
      startDate: startDate,
      createdAt: item?.createdAt ?? now,
      updatedAt: now,
    );
    return item!;
  }
}
