import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/widget_sync_service.dart';

final widgetSyncServiceProvider = Provider<WidgetSyncService>((ref) {
  return WidgetSyncService();
});
