import 'package:uuid/uuid.dart';

import '../models/monitor_hit.dart';
import '../models/monitor_source.dart';
import '../services/hive_service.dart';

class MonitorRepository {
  final HiveService? _hive;
  static const _uuid = Uuid();
  final Map<String, MonitorSource> _memorySources = {};
  final Map<String, MonitorHit> _memoryHits = {};

  MonitorRepository(this._hive);

  List<MonitorSource> getAllSources() {
    final hive = _hive;
    if (hive == null) return _memorySources.values.toList();
    return hive.getAllMonitorSources();
  }

  MonitorSource? getSource(String id) {
    final hive = _hive;
    if (hive == null) return _memorySources[id];
    return hive.getMonitorSource(id);
  }

  Future<void> saveSource(MonitorSource source) async {
    final hive = _hive;
    if (hive == null) {
      _memorySources[source.id] = source;
      return;
    }
    await hive.saveMonitorSource(source);
  }

  Future<MonitorSource> createSource({
    required String schoolName,
    required String sourceName,
    required String url,
    required MonitorSourceType sourceType,
    required List<String> keywords,
    required bool isEnabled,
  }) async {
    final now = DateTime.now();
    final source = MonitorSource(
      id: _uuid.v4(),
      schoolName: schoolName,
      sourceName: sourceName,
      url: url,
      sourceType: sourceType,
      keywords: keywords,
      isEnabled: isEnabled,
      lastCheckedAt: null,
      lastStatus: null,
      createdAt: now,
      updatedAt: now,
    );
    await saveSource(source);
    return source;
  }

  Future<MonitorSource> updateSource({
    required String id,
    required String schoolName,
    required String sourceName,
    required String url,
    required MonitorSourceType sourceType,
    required List<String> keywords,
    required bool isEnabled,
  }) async {
    final existing = getSource(id);
    if (existing == null) throw Exception('Monitor source not found: $id');
    final updated = existing.copyWith(
      schoolName: schoolName,
      sourceName: sourceName,
      url: url,
      sourceType: sourceType,
      keywords: keywords,
      isEnabled: isEnabled,
      updatedAt: DateTime.now(),
    );
    await saveSource(updated);
    return updated;
  }

  Future<void> deleteSource(String id) async {
    final hive = _hive;
    if (hive == null) {
      _memorySources.remove(id);
      return;
    }
    await hive.deleteMonitorSource(id);
  }

  List<MonitorHit> getHitsForSource(String sourceId) {
    final hive = _hive;
    final hits = hive == null ? _memoryHits.values : hive.getAllMonitorHits();
    return hits.where((hit) => hit.sourceId == sourceId).toList()
      ..sort((a, b) => b.discoveredAt.compareTo(a.discoveredAt));
  }

  List<MonitorHit> getAllHits() {
    final hive = _hive;
    final hits =
        hive == null ? _memoryHits.values.toList() : hive.getAllMonitorHits();
    return hits..sort((a, b) => b.discoveredAt.compareTo(a.discoveredAt));
  }

  bool hasFingerprint(String fingerprint) {
    final hive = _hive;
    final hits = hive == null ? _memoryHits.values : hive.getAllMonitorHits();
    return hits.any((hit) => hit.contentFingerprint == fingerprint);
  }

  Future<void> saveHit(MonitorHit hit) async {
    final hive = _hive;
    if (hive == null) {
      _memoryHits[hit.id] = hit;
      return;
    }
    await hive.saveMonitorHit(hit);
  }

  String nextId() => _uuid.v4();
}
