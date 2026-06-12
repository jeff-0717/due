import 'dart:convert';

import 'package:hive/hive.dart';

import '../models/countdown.dart';
import '../models/monitor_hit.dart';
import '../models/monitor_source.dart';
import '../models/review_start.dart';
import '../models/study_session.dart';
import '../models/widget_config.dart';

class HiveService {
  static const String countdownBoxName = 'countdowns';
  static const String reviewStartBoxName = 'review_start';
  static const String widgetConfigBoxName = 'widget_config';
  static const String homeConfigBoxName = 'home_config';
  static const String _homeSelectedCountdownKey = 'selected_countdown_id';
  static const String monitorSourceBoxName = 'monitor_sources';
  static const String monitorHitBoxName = 'monitor_hits';
  static const String studySessionBoxName = 'study_sessions';

  late Box<String> _countdownBox;
  late Box<String> _reviewStartBox;
  late Box<String> _widgetConfigBox;
  late Box<String> _homeConfigBox;
  late Box<String> _monitorSourceBox;
  late Box<String> _monitorHitBox;
  late Box<String> _studySessionBox;

  Future<void> init() async {
    _countdownBox = await Hive.openBox<String>(countdownBoxName);
    _reviewStartBox = await Hive.openBox<String>(reviewStartBoxName);
    _widgetConfigBox = await Hive.openBox<String>(widgetConfigBoxName);
    _homeConfigBox = await Hive.openBox<String>(homeConfigBoxName);
    _monitorSourceBox = await Hive.openBox<String>(monitorSourceBoxName);
    _monitorHitBox = await Hive.openBox<String>(monitorHitBoxName);
    _studySessionBox = await Hive.openBox<String>(studySessionBoxName);
  }

  // Countdown
  Future<void> saveCountdown(Countdown item) async {
    await _countdownBox.put(item.id, jsonEncode(item.toJson()));
  }

  Countdown? getCountdown(String id) {
    final raw = _countdownBox.get(id);
    if (raw == null) return null;
    return Countdown.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  List<Countdown> getAllCountdowns() {
    return _countdownBox.values
        .map((raw) =>
            Countdown.fromJson(jsonDecode(raw) as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteCountdown(String id) async {
    await _countdownBox.delete(id);
  }

  // ReviewStart
  Future<void> saveReviewStart(ReviewStart item) async {
    await _reviewStartBox.put(item.id, jsonEncode(item.toJson()));
  }

  ReviewStart? getReviewStart(String id) {
    final raw = _reviewStartBox.get(id);
    if (raw == null) return null;
    return ReviewStart.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  List<ReviewStart> getAllReviewStarts() {
    return _reviewStartBox.values
        .map((raw) =>
            ReviewStart.fromJson(jsonDecode(raw) as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteReviewStart(String id) async {
    await _reviewStartBox.delete(id);
  }

  // WidgetConfig
  Future<void> saveWidgetConfig(WidgetConfig item) async {
    await _widgetConfigBox.put(item.id, jsonEncode(item.toJson()));
  }

  WidgetConfig? getWidgetConfig(String id) {
    final raw = _widgetConfigBox.get(id);
    if (raw == null) return null;
    return WidgetConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  List<WidgetConfig> getAllWidgetConfigs() {
    return _widgetConfigBox.values
        .map((raw) =>
            WidgetConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteWidgetConfig(String id) async {
    await _widgetConfigBox.delete(id);
  }

  String? getHomeSelectedCountdownId() {
    final value = _homeConfigBox.get(_homeSelectedCountdownKey);
    return value == null || value.trim().isEmpty ? null : value;
  }

  Future<void> saveHomeSelectedCountdownId(String? countdownId) async {
    final value = countdownId?.trim();
    if (value == null || value.isEmpty) {
      await _homeConfigBox.delete(_homeSelectedCountdownKey);
      return;
    }
    await _homeConfigBox.put(_homeSelectedCountdownKey, value);
  }

  Future<void> saveMonitorSource(MonitorSource item) async {
    await _monitorSourceBox.put(item.id, jsonEncode(item.toJson()));
  }

  MonitorSource? getMonitorSource(String id) {
    final raw = _monitorSourceBox.get(id);
    if (raw == null) return null;
    return MonitorSource.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  List<MonitorSource> getAllMonitorSources() {
    return _monitorSourceBox.values
        .map((raw) =>
            MonitorSource.fromJson(jsonDecode(raw) as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteMonitorSource(String id) async {
    await _monitorSourceBox.delete(id);
  }

  Future<void> saveMonitorHit(MonitorHit item) async {
    await _monitorHitBox.put(item.id, jsonEncode(item.toJson()));
  }

  List<MonitorHit> getAllMonitorHits() {
    return _monitorHitBox.values
        .map((raw) =>
            MonitorHit.fromJson(jsonDecode(raw) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveStudySession(StudySession item) async {
    await _studySessionBox.put(item.id, jsonEncode(item.toJson()));
  }

  List<StudySession> getAllStudySessions() {
    return _studySessionBox.values
        .map((raw) =>
            StudySession.fromJson(jsonDecode(raw) as Map<String, dynamic>))
        .toList();
  }

  // Clear all
  Future<void> clearAll() async {
    await _countdownBox.clear();
    await _reviewStartBox.clear();
    await _widgetConfigBox.clear();
    await _homeConfigBox.clear();
    await _monitorSourceBox.clear();
    await _monitorHitBox.clear();
    await _studySessionBox.clear();
  }
}
