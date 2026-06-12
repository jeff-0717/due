import '../services/hive_service.dart';

class HomeConfigRepository {
  final HiveService _hive;

  const HomeConfigRepository(this._hive);

  String? getSelectedCountdownId() => _hive.getHomeSelectedCountdownId();

  Future<void> saveSelectedCountdownId(String? countdownId) async {
    await _hive.saveHomeSelectedCountdownId(countdownId);
  }
}
