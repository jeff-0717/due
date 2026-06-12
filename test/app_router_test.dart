import 'package:due/app.dart';
import 'package:due/providers/countdown_provider.dart';
import 'package:due/providers/home_config_provider.dart';
import 'package:due/providers/monitor_provider.dart';
import 'package:due/providers/review_start_provider.dart';
import 'package:due/providers/study_session_provider.dart';
import 'package:due/repositories/countdown_repository.dart';
import 'package:due/repositories/home_config_repository.dart';
import 'package:due/repositories/monitor_repository.dart';
import 'package:due/repositories/review_start_repository.dart';
import 'package:due/repositories/study_session_repository.dart';
import 'package:due/services/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('bottom navigation exposes four top-level destinations',
      (tester) async {
    await tester.pumpWidget(_buildApp());

    expect(find.byType(NavigationDestination), findsNWidgets(4));
    expect(find.text('首页'), findsOneWidget);
    expect(find.text('院校'), findsOneWidget);
    expect(find.text('记录'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
  });

  testWidgets('bottom navigation opens record and monitor pages',
      (tester) async {
    await tester.pumpWidget(_buildApp());

    await tester.tap(find.text('记录'));
    await tester.pumpAndSettle();
    expect(find.text('45:00'), findsOneWidget);

    await tester.tap(find.text('院校'));
    await tester.pumpAndSettle();
    expect(find.text('暂无监控源'), findsOneWidget);
  });

  testWidgets('monitor hit records are not a bottom tab', (tester) async {
    await tester.pumpWidget(_buildApp());

    expect(find.byType(NavigationDestination), findsNWidgets(4));
    expect(find.text('命中记录'), findsNothing);
  });
}

Widget _buildApp() {
  return ProviderScope(
    overrides: [
      countdownRepositoryProvider.overrideWithValue(_FakeCountdownRepository()),
      reviewStartRepositoryProvider.overrideWithValue(
        _FakeReviewStartRepository(),
      ),
      homeConfigRepositoryProvider.overrideWithValue(
        _FakeHomeConfigRepository(),
      ),
      monitorRepositoryProvider.overrideWithValue(MonitorRepository(null)),
      studySessionRepositoryProvider.overrideWithValue(
        _FakeStudySessionRepository(),
      ),
    ],
    child: const DueApp(),
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

class _FakeHomeConfigRepository extends HomeConfigRepository {
  _FakeHomeConfigRepository() : super(HiveService());

  @override
  String? getSelectedCountdownId() => null;

  @override
  Future<void> saveSelectedCountdownId(String? countdownId) async {}
}

class _FakeStudySessionRepository extends StudySessionRepository {
  _FakeStudySessionRepository() : super(HiveService());

  @override
  getAll() => [];
}
