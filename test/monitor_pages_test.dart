import 'package:due/models/monitor_source.dart';
import 'package:due/pages/home_page.dart';
import 'package:due/pages/monitor_list_page.dart';
import 'package:due/providers/countdown_provider.dart';
import 'package:due/providers/monitor_provider.dart';
import 'package:due/providers/review_start_provider.dart';
import 'package:due/repositories/countdown_repository.dart';
import 'package:due/repositories/monitor_repository.dart';
import 'package:due/repositories/review_start_repository.dart';
import 'package:due/services/hive_service.dart';
import 'package:due/services/monitor_check_service.dart';
import 'package:due/services/monitor_fetch_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('home exposes monitor entry without hiding countdown entry',
      (tester) async {
    await tester.pumpWidget(_buildApp('/'));

    expect(find.text('School Monitoring'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('monitor list renders empty, data and manual check state',
      (tester) async {
    await tester.pumpWidget(_buildApp('/monitor'));

    expect(find.text('No monitor sources yet'), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MonitorListPage)),
    );
    await container.read(monitorSourceListProvider.notifier).add(
          schoolName: 'North University',
          sourceName: 'Graduate notices',
          url: 'https://example.edu/feed',
          sourceType: MonitorSourceType.rss,
          keywords: const ['exam'],
          isEnabled: true,
        );
    await tester.pump();

    expect(find.text('North University'), findsOneWidget);
    expect(find.textContaining('Never checked'), findsOneWidget);
  });
}

Widget _buildApp(String initialLocation) {
  final monitorRepository = MonitorRepository(null);
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HomePage()),
      GoRoute(path: '/monitor', builder: (_, __) => const MonitorListPage()),
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
        builder: (_, __) => const Scaffold(body: Text('Edit route')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      countdownRepositoryProvider.overrideWithValue(
        _FakeCountdownRepository(),
      ),
      reviewStartRepositoryProvider.overrideWithValue(
        _FakeReviewStartRepository(),
      ),
      monitorRepositoryProvider.overrideWithValue(monitorRepository),
      monitorCheckServiceProvider.overrideWithValue(
        MonitorCheckService(
          repository: monitorRepository,
          fetcher: _EmptyFetcher(),
        ),
      ),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

class _FakeCountdownRepository extends CountdownRepository {
  _FakeCountdownRepository() : super(HiveService());

  @override
  getAll() => [];
}

class _FakeReviewStartRepository extends ReviewStartRepository {
  _FakeReviewStartRepository() : super(HiveService());

  @override
  get() => null;
}

class _EmptyFetcher implements MonitorCandidateFetcher {
  @override
  Future<MonitorFetchResult> fetchCandidates(MonitorSource source) async {
    return const MonitorFetchResult.success([]);
  }
}
