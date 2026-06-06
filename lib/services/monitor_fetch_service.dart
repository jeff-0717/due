import 'dart:convert';
import 'dart:io';

import '../models/monitor_source.dart';

abstract class MonitorCandidateFetcher {
  Future<MonitorFetchResult> fetchCandidates(MonitorSource source);
}

class MonitorCandidate {
  final String title;
  final String link;
  final String summary;
  final DateTime? publishedAt;

  const MonitorCandidate({
    required this.title,
    required this.link,
    required this.summary,
    required this.publishedAt,
  });
}

class MonitorFetchResult {
  final List<MonitorCandidate> candidates;
  final String? errorMessage;

  const MonitorFetchResult.success(this.candidates) : errorMessage = null;
  const MonitorFetchResult.failure(this.errorMessage) : candidates = const [];

  bool get isSuccess => errorMessage == null;
}

class MonitorHttpResponse {
  final int statusCode;
  final String body;

  const MonitorHttpResponse({
    required this.statusCode,
    required this.body,
  });
}

abstract class MonitorHttpClient {
  Future<MonitorHttpResponse> get(Uri uri);
}

class DartIoMonitorHttpClient implements MonitorHttpClient {
  final HttpClient _client;

  DartIoMonitorHttpClient({HttpClient? client})
      : _client = client ?? HttpClient();

  @override
  Future<MonitorHttpResponse> get(Uri uri) async {
    final request = await _client.getUrl(uri);
    final response = await request.close();
    final body = await utf8.decodeStream(response);
    return MonitorHttpResponse(statusCode: response.statusCode, body: body);
  }
}

class MonitorFetchService implements MonitorCandidateFetcher {
  final MonitorHttpClient _client;

  MonitorFetchService({MonitorHttpClient? client})
      : _client = client ?? DartIoMonitorHttpClient();

  @override
  Future<MonitorFetchResult> fetchCandidates(MonitorSource source) async {
    try {
      final response = await _client.get(Uri.parse(source.url));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return MonitorFetchResult.failure('请求失败，状态码 ${response.statusCode}');
      }
      if (source.sourceType == MonitorSourceType.rss) {
        return MonitorFetchResult.success(_parseRss(response.body, source.url));
      }
      return MonitorFetchResult.success(_parseHtml(response.body, source.url));
    } catch (_) {
      return const MonitorFetchResult.failure('请求失败，请检查网址或网络');
    }
  }

  List<MonitorCandidate> _parseRss(String body, String sourceUrl) {
    final items = RegExp(r'<item\b[\s\S]*?</item>', caseSensitive: false)
        .allMatches(body)
        .map((match) => match.group(0)!)
        .toList();
    return items.map((item) {
      final title = _decodeEntities(_tag(item, 'title') ?? '未命名公告');
      final link = _decodeEntities(_tag(item, 'link') ?? sourceUrl);
      final summary =
          _decodeEntities(_stripTags(_tag(item, 'description') ?? ''));
      final pubDate = _tag(item, 'pubDate');
      return MonitorCandidate(
        title: title,
        link: link.trim().isEmpty ? sourceUrl : link.trim(),
        summary: summary,
        publishedAt: pubDate != null ? DateTime.tryParse(pubDate) : null,
      );
    }).toList();
  }

  List<MonitorCandidate> _parseHtml(String body, String sourceUrl) {
    final withoutScripts = body
        .replaceAll(
            RegExp(r'<script\b[\s\S]*?</script>', caseSensitive: false), ' ')
        .replaceAll(
            RegExp(r'<style\b[\s\S]*?</style>', caseSensitive: false), ' ');
    final linkCandidates = _parseHtmlLinks(withoutScripts, sourceUrl);
    return linkCandidates;
  }

  List<MonitorCandidate> _parseHtmlLinks(String body, String sourceUrl) {
    final matches = RegExp(r'<a\b([^>]*)>([\s\S]*?)</a>', caseSensitive: false)
        .allMatches(body);
    final candidates = <MonitorCandidate>[];
    final seen = <String>{};
    for (final match in matches) {
      final attributes = match.group(1) ?? '';
      final hrefMatch = RegExp(
        r'''href\s*=\s*["']([^"']+)["']''',
        caseSensitive: false,
      ).firstMatch(attributes);
      final rawHref = _decodeEntities(hrefMatch?.group(1) ?? '').trim();
      final rawTitle = _decodeEntities(_stripTags(match.group(2) ?? '')).trim();
      if (rawHref.isEmpty || rawTitle.isEmpty) continue;
      if (rawHref.startsWith('#') ||
          rawHref.toLowerCase().startsWith('javascript:')) {
        continue;
      }
      final link = _resolveLink(sourceUrl, rawHref);
      final key = '$link|$rawTitle';
      if (!seen.add(key)) continue;
      candidates.add(
        MonitorCandidate(
          title: rawTitle,
          link: link,
          summary: rawTitle,
          publishedAt: null,
        ),
      );
    }
    return candidates;
  }

  String _resolveLink(String sourceUrl, String href) {
    final base = Uri.parse(sourceUrl);
    final resolved = base.resolve(href);
    return resolved.toString();
  }

  String? _tag(String body, String tag) {
    final match = RegExp('<$tag[^>]*>([\\s\\S]*?)</$tag>', caseSensitive: false)
        .firstMatch(body);
    return match?.group(1)?.trim();
  }

  String _stripTags(String value) {
    return _compact(value.replaceAll(RegExp(r'<[^>]+>'), ' '));
  }

  String _compact(String value, {int? maxLength}) {
    final compacted = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (maxLength == null || compacted.length <= maxLength) return compacted;
    return compacted.substring(0, maxLength);
  }

  String _decodeEntities(String value) {
    return value
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ');
  }
}
