import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review_start.dart';
import '../repositories/review_start_repository.dart';
import 'hive_provider.dart';

final reviewStartRepositoryProvider = Provider<ReviewStartRepository>((ref) {
  return ReviewStartRepository(ref.watch(hiveServiceProvider));
});

final reviewStartProvider =
    StateNotifierProvider<ReviewStartNotifier, ReviewStart?>((ref) {
  return ReviewStartNotifier(ref.watch(reviewStartRepositoryProvider));
});

class ReviewStartNotifier extends StateNotifier<ReviewStart?> {
  final ReviewStartRepository _repository;

  ReviewStartNotifier(this._repository) : super(null) {
    _load();
  }

  void _load() {
    state = _repository.get();
  }

  Future<void> set(DateTime startDate) async {
    state = await _repository.set(startDate);
  }

  Future<void> clear() async {
    await _repository.clear();
    state = null;
  }

  void refresh() => _load();
}
