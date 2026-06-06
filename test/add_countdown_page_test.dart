import 'package:due/models/countdown.dart';
import 'package:due/pages/add_countdown_page.dart';
import 'package:due/providers/countdown_provider.dart';
import 'package:due/repositories/countdown_repository.dart';
import 'package:due/services/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('add page validates title before saving', (tester) async {
    final repository = _FakeCountdownRepository();
    await tester.pumpWidget(_buildAddPage(repository));

    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('Title is required'), findsOneWidget);
    expect(repository.created, isEmpty);
  });

  testWidgets('add page saves selected countdown and returns home',
      (tester) async {
    final repository = _FakeCountdownRepository();
    await tester.pumpWidget(_buildAddPage(repository));

    await tester.enterText(find.byType(TextField), 'Final Exam');
    await tester.tap(find.text('Yearly'));
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(repository.created.single.title, 'Final Exam');
    expect(repository.created.single.repeatType, RepeatType.yearly);
    expect(find.text('Home route'), findsOneWidget);
  });
}

Widget _buildAddPage(_FakeCountdownRepository repository) {
  final router = GoRouter(
    initialLocation: '/add',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const Scaffold(body: Text('Home route')),
      ),
      GoRoute(path: '/add', builder: (_, __) => const AddCountdownPage()),
    ],
  );

  return ProviderScope(
    overrides: [
      countdownRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

class _FakeCountdownRepository extends CountdownRepository {
  _FakeCountdownRepository() : super(HiveService());

  final List<Countdown> created = [];

  @override
  List<Countdown> getAll() => created;

  @override
  Future<Countdown> create({
    required String title,
    required DateTime targetDate,
    required String repeatType,
    required String color,
    required String icon,
  }) async {
    final now = DateTime.now();
    final item = Countdown(
      id: 'created-${created.length}',
      title: title,
      targetDate: targetDate,
      repeatType: RepeatType.values.firstWhere((e) => e.name == repeatType),
      color: color,
      icon: icon,
      createdAt: now,
      updatedAt: now,
    );
    created.add(item);
    return item;
  }
}
