import 'package:flutter/services.dart';

import '../repositories/monitor_repository.dart';

class MonitorNotificationService {
  static const channel = MethodChannel('due/monitor_notifications');

  final MonitorRepository _repository;

  const MonitorNotificationService(this._repository);

  Future<int> notifyNewHits() async {
    var sent = 0;
    final now = DateTime.now();
    for (final hit in _repository.getAllHits()) {
      if (hit.notificationSentAt != null) continue;
      await channel.invokeMethod<void>('showMonitorHit', {
        'id': hit.id,
        'title': hit.title,
        'summary': hit.summary,
        'sourceId': hit.sourceId,
        'link': hit.link,
      });
      await _repository.saveHit(hit.copyWith(notificationSentAt: now));
      sent++;
    }
    return sent;
  }
}
