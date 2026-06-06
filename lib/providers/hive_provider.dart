import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/hive_service.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});
