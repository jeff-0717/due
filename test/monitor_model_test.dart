import 'package:due/models/monitor_hit.dart';
import 'package:due/models/monitor_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('monitor source serializes all persisted fields', () {
    final now = DateTime(2026, 6, 6, 9);
    final source = MonitorSource(
      id: 'source-1',
      schoolName: 'North University',
      sourceName: 'Graduate notices',
      url: 'https://example.edu/rss.xml',
      sourceType: MonitorSourceType.rss,
      keywords: const ['exam', 'admission'],
      isEnabled: true,
      lastCheckedAt: now,
      lastStatus: 'new_hits',
      createdAt: now,
      updatedAt: now,
    );

    final decoded = MonitorSource.fromJson(source.toJson());

    expect(decoded.schoolName, 'North University');
    expect(decoded.sourceType, MonitorSourceType.rss);
    expect(decoded.keywords, ['exam', 'admission']);
    expect(decoded.lastStatus, 'new_hits');
  });

  test('monitor hit serializes source, matched keywords and fingerprint', () {
    final now = DateTime(2026, 6, 6, 9);
    final hit = MonitorHit(
      id: 'hit-1',
      sourceId: 'source-1',
      title: 'Exam admission notice',
      link: 'https://example.edu/notice',
      summary: 'Admission arrangements are published.',
      matchedKeywords: const ['exam', 'admission'],
      publishedAt: now,
      discoveredAt: now,
      contentFingerprint: 'source-1|notice',
      notificationSentAt: null,
      createdAt: now,
    );

    final decoded = MonitorHit.fromJson(hit.toJson());

    expect(decoded.sourceId, 'source-1');
    expect(decoded.matchedKeywords, ['exam', 'admission']);
    expect(decoded.contentFingerprint, 'source-1|notice');
    expect(decoded.notificationSentAt, isNull);
  });
}
