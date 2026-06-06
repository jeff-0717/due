import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/widget_config.dart';
import '../repositories/widget_config_repository.dart';
import 'hive_provider.dart';

final widgetConfigRepositoryProvider = Provider<WidgetConfigRepository>((ref) {
  return WidgetConfigRepository(ref.watch(hiveServiceProvider));
});

final widgetConfigProvider =
    StateNotifierProvider<WidgetConfigNotifier, WidgetConfig?>((ref) {
  return WidgetConfigNotifier(ref.watch(widgetConfigRepositoryProvider));
});

class WidgetConfigNotifier extends StateNotifier<WidgetConfig?> {
  final WidgetConfigRepository _repository;

  WidgetConfigNotifier(this._repository) : super(null) {
    _load();
  }

  void _load() {
    state = _repository.get();
  }

  Future<void> set(String countdownId, String style) async {
    state = await _repository.set(countdownId, style);
  }

  Future<void> clear() async {
    await _repository.clear();
    state = null;
  }

  void refresh() => _load();
}
