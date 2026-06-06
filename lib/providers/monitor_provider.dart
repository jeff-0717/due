import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/monitor_hit.dart';
import '../models/monitor_source.dart';
import '../repositories/monitor_repository.dart';
import '../services/monitor_check_service.dart';
import '../services/monitor_fetch_service.dart';
import 'hive_provider.dart';

final monitorRepositoryProvider = Provider<MonitorRepository>((ref) {
  return MonitorRepository(ref.watch(hiveServiceProvider));
});

final monitorFetchServiceProvider = Provider<MonitorCandidateFetcher>((ref) {
  return MonitorFetchService();
});

final monitorCheckServiceProvider = Provider<MonitorCheckService>((ref) {
  return MonitorCheckService(
    repository: ref.watch(monitorRepositoryProvider),
    fetcher: ref.watch(monitorFetchServiceProvider),
  );
});

final monitorSourceListProvider =
    StateNotifierProvider<MonitorSourceListNotifier, List<MonitorSource>>((ref) {
  return MonitorSourceListNotifier(ref.watch(monitorRepositoryProvider));
});

final monitorHitListProvider =
    StateNotifierProvider<MonitorHitListNotifier, List<MonitorHit>>((ref) {
  return MonitorHitListNotifier(ref.watch(monitorRepositoryProvider));
});

final monitorCheckStateProvider = StateNotifierProvider<MonitorCheckNotifier,
    Map<String, MonitorCheckResult>>((ref) {
  return MonitorCheckNotifier(
    ref.watch(monitorCheckServiceProvider),
    ref.watch(monitorSourceListProvider.notifier),
    ref.watch(monitorHitListProvider.notifier),
  );
});

class MonitorSourceListNotifier extends StateNotifier<List<MonitorSource>> {
  final MonitorRepository _repository;

  MonitorSourceListNotifier(this._repository) : super([]) {
    refresh();
  }

  void refresh() {
    state = _repository.getAllSources();
  }

  Future<void> add({
    required String schoolName,
    required String sourceName,
    required String url,
    required MonitorSourceType sourceType,
    required List<String> keywords,
    required bool isEnabled,
  }) async {
    await _repository.createSource(
      schoolName: schoolName,
      sourceName: sourceName,
      url: url,
      sourceType: sourceType,
      keywords: keywords,
      isEnabled: isEnabled,
    );
    refresh();
  }

  Future<void> update({
    required String id,
    required String schoolName,
    required String sourceName,
    required String url,
    required MonitorSourceType sourceType,
    required List<String> keywords,
    required bool isEnabled,
  }) async {
    await _repository.updateSource(
      id: id,
      schoolName: schoolName,
      sourceName: sourceName,
      url: url,
      sourceType: sourceType,
      keywords: keywords,
      isEnabled: isEnabled,
    );
    refresh();
  }

  Future<void> delete(String id) async {
    await _repository.deleteSource(id);
    refresh();
  }
}

class MonitorHitListNotifier extends StateNotifier<List<MonitorHit>> {
  final MonitorRepository _repository;

  MonitorHitListNotifier(this._repository) : super([]) {
    refresh();
  }

  void refresh() {
    state = _repository.getAllHits();
  }

  List<MonitorHit> forSource(String sourceId) {
    return state.where((hit) => hit.sourceId == sourceId).toList();
  }
}

class MonitorCheckNotifier
    extends StateNotifier<Map<String, MonitorCheckResult>> {
  final MonitorCheckService _service;
  final MonitorSourceListNotifier _sources;
  final MonitorHitListNotifier _hits;

  MonitorCheckNotifier(this._service, this._sources, this._hits) : super({});

  Future<MonitorCheckResult> check(String sourceId) async {
    final result = await _service.checkSource(sourceId);
    state = {...state, sourceId: result};
    _sources.refresh();
    _hits.refresh();
    return result;
  }
}
