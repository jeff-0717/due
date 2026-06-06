import 'package:due/models/monitor_source.dart';
import 'package:due/services/monitor_fetch_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fetch parses rss items into monitor candidates', () async {
    final service = MonitorFetchService(
      client: _FakeHttpClient('''
<rss><channel>
  <item>
    <title>Exam registration opens</title>
    <link>https://example.edu/exam</link>
    <description>Admission exam registration notice.</description>
    <pubDate>Sat, 06 Jun 2026 09:00:00 GMT</pubDate>
  </item>
</channel></rss>
'''),
    );

    final result =
        await service.fetchCandidates(_source(MonitorSourceType.rss));

    expect(result.isSuccess, isTrue);
    expect(result.candidates, hasLength(1));
    expect(result.candidates.single.title, 'Exam registration opens');
    expect(result.candidates.single.link, 'https://example.edu/exam');
    expect(result.candidates.single.summary, contains('Admission exam'));
  });

  test('fetch extracts title and readable text from static html', () async {
    final service = MonitorFetchService(
      client: _FakeHttpClient('''
<html>
<head><title>Graduate admission update</title></head>
<body><script>ignored()</script><main>复试 exam schedule published.</main></body>
</html>
'''),
    );

    final result =
        await service.fetchCandidates(_source(MonitorSourceType.webPage));

    expect(result.isSuccess, isTrue);
    expect(result.candidates.single.title, 'Graduate admission update');
    expect(result.candidates.single.summary, contains('exam schedule'));
    expect(result.candidates.single.summary, isNot(contains('ignored')));
  });

  test('fetch splits static html notice links into candidates', () async {
    final service = MonitorFetchService(
      client: _FakeHttpClient('''
<html>
<head><title>东南大学研究生招生网</title></head>
<body>
  <ul>
    <li><a href="/2026/notice-a.htm">东南大学2026年硕士研究生复试须知</a></li>
    <li><a href="https://yzb.seu.edu.cn/2026/tiaoji.htm">东南大学2026年硕士研究生调剂信息汇总</a></li>
  </ul>
</body>
</html>
'''),
    );

    final result =
        await service.fetchCandidates(_source(MonitorSourceType.webPage));

    expect(result.isSuccess, isTrue);
    expect(result.candidates, hasLength(2));
    expect(result.candidates.first.title, contains('复试须知'));
    expect(
        result.candidates.first.link, 'https://example.edu/2026/notice-a.htm');
    expect(result.candidates.last.title, contains('调剂信息'));
  });

  test('fetch failure returns displayable error instead of throwing', () async {
    final service = MonitorFetchService(
      client: _FakeHttpClient('Missing', statusCode: 404),
    );

    final result =
        await service.fetchCandidates(_source(MonitorSourceType.rss));

    expect(result.isSuccess, isFalse);
    expect(result.errorMessage, contains('状态码 404'));
  });
}

class _FakeHttpClient implements MonitorHttpClient {
  _FakeHttpClient(this.body, {this.statusCode = 200});

  final String body;
  final int statusCode;

  @override
  Future<MonitorHttpResponse> get(Uri uri) async {
    return MonitorHttpResponse(statusCode: statusCode, body: body);
  }
}

MonitorSource _source(MonitorSourceType type) {
  final now = DateTime(2026, 6, 6, 9);
  return MonitorSource(
    id: 'source-1',
    schoolName: 'North University',
    sourceName: 'Notices',
    url: 'https://example.edu/feed',
    sourceType: type,
    keywords: const ['exam'],
    isEnabled: true,
    lastCheckedAt: null,
    lastStatus: null,
    createdAt: now,
    updatedAt: now,
  );
}
