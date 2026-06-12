import 'package:flutter/services.dart';

typedef FocusNotificationActionHandler = Future<void> Function(String action);

class FocusNotificationService {
  static const channel = MethodChannel('due/focus_notifications');
  static const actionPause = 'pause';
  static const actionResume = 'resume';
  static const actionFinish = 'finish';

  const FocusNotificationService();

  Future<void> showRunningTimer({
    required int? plannedSeconds,
    required int remainingSeconds,
    required bool isRunning,
    required String mode,
  }) async {
    await channel.invokeMethod<void>('showRunningTimer', {
      'plannedSeconds': plannedSeconds,
      'remainingSeconds': remainingSeconds,
      'isRunning': isRunning,
      'mode': mode,
    });
  }

  Future<void> cancel() async {
    await channel.invokeMethod<void>('cancel');
  }

  void setActionHandler(FocusNotificationActionHandler? handler) {
    if (handler == null) {
      channel.setMethodCallHandler(null);
      return;
    }
    channel.setMethodCallHandler((call) async {
      if (call.method != 'focusTimerAction') return;
      final arguments = call.arguments;
      if (arguments is! Map) return;
      final action = arguments['action'] as String?;
      if (action == null || action.isEmpty) return;
      await handler(action);
    });
  }
}
