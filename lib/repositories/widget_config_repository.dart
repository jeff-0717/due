import '../models/widget_config.dart';
import '../services/hive_service.dart';

class WidgetConfigRepository {
  final HiveService _hive;
  const WidgetConfigRepository(this._hive);

  static const _defaultId = 'default';

  WidgetConfig? get() => _hive.getWidgetConfig(_defaultId);

  Future<WidgetConfig> set(String countdownId, String style) async {
    final now = DateTime.now();
    final item = WidgetConfig(
      id: _defaultId,
      countdownId: countdownId,
      style: style,
      updatedAt: now,
    );
    await _hive.saveWidgetConfig(item);
    return item;
  }

  Future<void> clear() async {
    await _hive.deleteWidgetConfig(_defaultId);
  }
}
