import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/home_config_repository.dart';
import 'hive_provider.dart';

final homeConfigRepositoryProvider = Provider<HomeConfigRepository>((ref) {
  return HomeConfigRepository(ref.watch(hiveServiceProvider));
});

final homeSelectedCountdownProvider =
    StateNotifierProvider<HomeSelectedCountdownNotifier, String?>((ref) {
  return HomeSelectedCountdownNotifier(ref.watch(homeConfigRepositoryProvider));
});

class HomeSelectedCountdownNotifier extends StateNotifier<String?> {
  final HomeConfigRepository _repository;

  HomeSelectedCountdownNotifier(this._repository) : super(null) {
    _load();
  }

  void _load() {
    state = _repository.getSelectedCountdownId();
  }

  Future<void> select(String? countdownId) async {
    await _repository.saveSelectedCountdownId(countdownId);
    state = countdownId;
  }
}
