import '../models/review_start.dart';
import '../services/hive_service.dart';

class ReviewStartRepository {
  final HiveService _hive;
  const ReviewStartRepository(this._hive);

  static const _defaultId = 'default';

  ReviewStart? get() => _hive.getReviewStart(_defaultId);

  Future<ReviewStart> set(DateTime startDate) async {
    final existing = _hive.getReviewStart(_defaultId);
    final now = DateTime.now();
    final item = ReviewStart(
      id: _defaultId,
      startDate: startDate,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    await _hive.saveReviewStart(item);
    return item;
  }

  Future<void> clear() async {
    await _hive.deleteReviewStart(_defaultId);
  }
}
