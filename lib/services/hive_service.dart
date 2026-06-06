import 'dart:convert';

import 'package:hive/hive.dart';

import '../models/countdown.dart';
import '../models/review_start.dart';
import '../models/widget_config.dart';

class HiveService {
  static const String countdownBoxName = 'countdowns';
  static const String reviewStartBoxName = 'review_start';
  static const String widgetConfigBoxName = 'widget_config';

  late Box<String> _countdownBox;
  late Box<String> _reviewStartBox;
  late Box<String> _widgetConfigBox;

  Future<void> init() async {
    _countdownBox = await Hive.openBox<String>(countdownBoxName);
    _reviewStartBox = await Hive.openBox<String>(reviewStartBoxName);
    _widgetConfigBox = await Hive.openBox<String>(widgetConfigBoxName);
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

  // Clear all
  Future<void> clearAll() async {
    await _countdownBox.clear();
    await _reviewStartBox.clear();
    await _widgetConfigBox.clear();
  }
}
