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

    expect(find.text('院校信息监控'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('monitor list renders empty, data and manual check state',
      (tester) async {
    await tester.pumpWidget(_buildApp('/monitor'));

    expect(find.text('暂无监控源'), findsOneWidget);

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
    expect(find.textContaining('尚未检查'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('monitor list keeps source visible after failed manual check',
      (tester) async {
    await tester.pumpWidget(
      _buildApp(
        '/monitor',
        fetcher: _FailingFetcher(),
      ),
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MonitorListPage)),
    );
    await container.read(monitorSourceListProvider.notifier).add(
          schoolName: '东南大学',
          sourceName: '研究生招生公告',
          url: 'https://yzb.seu.edu.cn',
          sourceType: MonitorSourceType.webPage,
          keywords: const ['2027年', '夏令营', '推免', '硕士研究生'],
          isEnabled: true,
        );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();
    await tester.pump();

    expect(find.text('东南大学'), findsOneWidget);
    expect(find.textContaining('检查失败'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

Widget _buildApp(
  String initialLocation, {
  MonitorCandidateFetcher? fetcher,
}) {
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
          fetcher: fetcher ?? _EmptyFetcher(),
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

class _FailingFetcher implements MonitorCandidateFetcher {
  @override
  Future<MonitorFetchResult> fetchCandidates(MonitorSource source) async {
    return const MonitorFetchResult.failure('请求失败，请检查网址或网络');
  }
}
