import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/countdown.dart';
import '../repositories/countdown_repository.dart';
import 'hive_provider.dart';

final countdownRepositoryProvider = Provider<CountdownRepository>((ref) {
  return CountdownRepository(ref.watch(hiveServiceProvider));
});

final countdownListProvider =
    StateNotifierProvider<CountdownListNotifier, List<Countdown>>((ref) {
  return CountdownListNotifier(ref.watch(countdownRepositoryProvider));
});

class CountdownListNotifier extends StateNotifier<List<Countdown>> {
  final CountdownRepository _repository;

  CountdownListNotifier(this._repository) : super([]) {
    _load();
  }

  void _load() {
    state = _repository.getAll();
  }

  Future<void> add({
    required String title,
    required DateTime targetDate,
    required String repeatType,
    required String color,
    required String icon,
  }) async {
    await _repository.create(
      title: title,
      targetDate: targetDate,
      repeatType: repeatType,
      color: color,
      icon: icon,
    );
    _load();
  }

  Future<void> update({
    required String id,
    required String title,
    required DateTime targetDate,
    required String repeatType,
    required String color,
    required String icon,
  }) async {
    await _repository.update(
      id: id,
      title: title,
      targetDate: targetDate,
      repeatType: repeatType,
      color: color,
      icon: icon,
    );
    _load();
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    _load();
  }

  void refresh() => _load();
}
