import 'package:due/models/monitor_source.dart';
import 'package:due/repositories/monitor_repository.dart';
import 'package:due/services/monitor_check_service.dart';
import 'package:due/services/monitor_fetch_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('manual check stores only new keyword hits and deduplicates repeats',
      () async {
    final now = DateTime(2026, 6, 6, 9);
    final source = MonitorSource(
      id: 'source-1',
      schoolName: 'North University',
      sourceName: 'Notices',
      url: 'https://example.edu/feed',
      sourceType: MonitorSourceType.rss,
      keywords: const ['exam', '复试'],
      isEnabled: true,
      lastCheckedAt: null,
      lastStatus: null,
      createdAt: now,
      updatedAt: now,
    );
    final repository = _MemoryMonitorRepository();
    await repository.saveSource(source);
    final service = MonitorCheckService(
      repository: repository,
      fetcher: _FakeFetcher([
        MonitorCandidate(
          title: 'Exam registration opens',
          link: 'https://example.edu/exam',
          summary: 'Admission exam registration notice.',
          publishedAt: now,
        ),
        MonitorCandidate(
          title: 'Campus cafeteria update',
          link: 'https://example.edu/food',
          summary: 'Menu changed.',
          publishedAt: now,
        ),
      ]),
    );

    final first = await service.checkSource(source.id);
    final second = await service.checkSource(source.id);

    expect(first.status, MonitorCheckStatus.newHits);
    expect(first.newHitCount, 1);
    expect(second.status, MonitorCheckStatus.noNewHits);
    expect(repository.getHitsForSource(source.id), hasLength(1));
    expect(repository.getHitsForSource(source.id).single.matchedKeywords,
        ['exam']);
  });

  test('first manual web page check stores existing matching notices', () async {
    final now = DateTime(2026, 6, 6, 9);
    final source = MonitorSource(
      id: 'source-1',
      schoolName: '东南大学',
      sourceName: '研究生招生公告',
      url: 'https://yzb.seu.edu.cn',
      sourceType: MonitorSourceType.webPage,
      keywords: const ['2026年', '硕士研究生'],
      isEnabled: true,
      lastCheckedAt: null,
      lastStatus: null,
      createdAt: now,
      updatedAt: now,
    );
    final repository = _MemoryMonitorRepository();
    await repository.saveSource(source);
    final service = MonitorCheckService(
      repository: repository,
      fetcher: _FakeFetcher([
        MonitorCandidate(
          title: '东南大学2026年硕士研究生复试须知',
          link: 'https://yzb.seu.edu.cn/2026/fushi.htm',
          summary: '复试安排和硕士研究生招生信息。',
          publishedAt: now,
        ),
      ]),
    );

    final result = await service.checkSource(source.id);

    expect(result.status, MonitorCheckStatus.newHits);
    expect(result.newHitCount, 1);
    expect(repository.getHitsForSource(source.id).single.title,
        contains('2026年硕士研究生'));
  });
}

class _FakeFetcher implements MonitorCandidateFetcher {
  _FakeFetcher(this.candidates);

  final List<MonitorCandidate> candidates;

  @override
  Future<MonitorFetchResult> fetchCandidates(MonitorSource source) async {
    return MonitorFetchResult.success(candidates);
  }
}

class _MemoryMonitorRepository extends MonitorRepository {
  _MemoryMonitorRepository() : super(null);
}
