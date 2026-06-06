import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

final monitorLinkOpenerProvider = Provider<MonitorLinkOpener>((ref) {
  return const UrlLauncherMonitorLinkOpener();
});

abstract class MonitorLinkOpener {
  Future<bool> open(String url);
}

class UrlLauncherMonitorLinkOpener implements MonitorLinkOpener {
  const UrlLauncherMonitorLinkOpener();

  static const _channel = MethodChannel('due/link_opener');

  @override
  Future<bool> open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return false;
    return await _channel.invokeMethod<bool>('openExternalUrl', {
          'url': uri.toString(),
        }) ??
        false;
  }
}
