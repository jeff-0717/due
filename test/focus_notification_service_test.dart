import 'package:due/services/focus_notification_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    FocusNotificationService.channel.setMethodCallHandler(null);
  });

  test('focus timer action from native is routed to handler', () async {
    final actions = <String>[];
    const service = FocusNotificationService();

    service.setActionHandler((action) async {
      actions.add(action);
    });

    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
      FocusNotificationService.channel.name,
      const StandardMethodCodec().encodeMethodCall(
        const MethodCall('focusTimerAction', {'action': 'pause'}),
      ),
      (_) {},
    );

    expect(actions, [FocusNotificationService.actionPause]);
  });
}
