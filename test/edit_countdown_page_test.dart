import 'package:due/models/countdown.dart';
import 'package:due/pages/edit_countdown_page.dart';
import 'package:due/providers/countdown_provider.dart';
import 'package:due/repositories/countdown_repository.dart';
import 'package:due/services/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('edit page shows fallback when countdown is missing',
      (tester) async {
    await tester.pumpWidget(_buildEditPage(_FakeCountdownRepository(), 'none'));
    await tester.pump();

    expect(find.text('未找到倒计时'), findsOneWidget);
    expect(find.text('返回首页'), findsOneWidget);
  });

  testWidgets('edit page updates existing countdown and returns home',
      (tester) async {
    final repository = _FakeCountdownRepository([_countdown(id: 'exam')]);
    await tester.pumpWidget(_buildEditPage(repository, 'exam'));
    await tester.pump();

    expect(find.text('Original Exam'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Updated Exam');
    await tester.tap(find.text('每年'));
    await tester.pump();
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(repository.items.single.title, 'Updated Exam');
    expect(repository.items.single.repeatType, RepeatType.yearly);
    expect(find.text('Home route'), findsOneWidget);
  });

  testWidgets('edit page deletes after confirmation and returns home',
      (tester) async {
    final repository = _FakeCountdownRepository([_countdown(id: 'exam')]);
    await tester.pumpWidget(_buildEditPage(repository, 'exam'));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除').last);
    await tester.pumpAndSettle();

    expect(repository.items, isEmpty);
    expect(find.text('Home route'), findsOneWidget);
  });
}

Widget _buildEditPage(_FakeCountdownRepository repository, String id) {
  final router = GoRouter(
    initialLocation: '/edit/$id',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const Scaffold(body: Text('Home route')),
      ),
      GoRoute(
        path: '/edit/:id',
        builder: (_, state) => EditCountdownPage(
          id: state.pathParameters['id']!,
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      countdownRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

Countdown _countdown({required String id}) {
  final now = DateTime.now();
  return Countdown(
    id: id,
    title: 'Original Exam',
    targetDate: now.add(const Duration(days: 20)),
    repeatType: RepeatType.once,
    color: '#2563EB',
    icon: 'E',
    createdAt: now,
    updatedAt: now,
  );
}

class _FakeCountdownRepository extends CountdownRepository {
  _FakeCountdownRepository([List<Countdown>? items])
      : items = [...?items],
        super(HiveService());

  final List<Countdown> items;

  @override
  List<Countdown> getAll() => items;

  @override
  Future<Countdown> update({
    required String id,
    required String title,
    required DateTime targetDate,
    required String repeatType,
    required String color,
    required String icon,
  }) async {
    final index = items.indexWhere((item) => item.id == id);
    if (index == -1) throw Exception('Countdown not found: $id');
    final updated = items[index].copyWith(
      title: title,
      targetDate: targetDate,
      repeatType: RepeatType.values.firstWhere((e) => e.name == repeatType),
      color: color,
      icon: icon,
      updatedAt: DateTime.now(),
    );
    items[index] = updated;
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    items.removeWhere((item) => item.id == id);
  }
}
