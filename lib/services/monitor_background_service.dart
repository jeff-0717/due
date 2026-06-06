import 'package:flutter/services.dart';

class MonitorBackgroundService {
  static const channel = MethodChannel('due/monitor_background');

  const MonitorBackgroundService();

  Future<void> configurePeriodicChecks({required int hours}) async {
    if (hours < 6 || hours > 12) {
      throw ArgumentError.value(hours, 'hours', 'Use a 6-12 hour interval');
    }
    await channel.invokeMethod<void>('configurePeriodicChecks', {
      'hours': hours,
    });
  }

  Future<void> triggerManualBackgroundCheck() async {
    await channel.invokeMethod<void>('triggerManualBackgroundCheck');
  }
}
