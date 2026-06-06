import 'package:uuid/uuid.dart';
import '../models/countdown.dart';
import '../services/hive_service.dart';

class CountdownRepository {
  final HiveService _hive;
  static const _uuid = Uuid();
  const CountdownRepository(this._hive);

  List<Countdown> getAll() => _hive.getAllCountdowns();

  Countdown? get(String id) => _hive.getCountdown(id);

  Future<void> save(Countdown item) async {
    await _hive.saveCountdown(item);
  }

  Future<void> delete(String id) async {
    await _hive.deleteCountdown(id);
  }

  Future<Countdown> create({
    required String title,
    required DateTime targetDate,
    required String repeatType,
    required String color,
    required String icon,
  }) async {
    final now = DateTime.now();
    final item = Countdown(
      id: _uuid.v4(),
      title: title,
      targetDate: targetDate,
      repeatType: RepeatType.values.firstWhere((e) => e.name == repeatType),
      color: color,
      icon: icon,
      createdAt: now,
      updatedAt: now,
    );
    await _hive.saveCountdown(item);
    return item;
  }

  Future<Countdown> update({
    required String id,
    required String title,
    required DateTime targetDate,
    required String repeatType,
    required String color,
    required String icon,
  }) async {
    final existing = _hive.getCountdown(id);
    if (existing == null) throw Exception('Countdown not found: $id');
    final updated = existing.copyWith(
      title: title,
      targetDate: targetDate,
      repeatType: RepeatType.values.firstWhere((e) => e.name == repeatType),
      color: color,
      icon: icon,
      updatedAt: DateTime.now(),
    );
    await _hive.saveCountdown(updated);
    return updated;
  }
}
