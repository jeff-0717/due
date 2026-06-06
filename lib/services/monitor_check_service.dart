import '../models/monitor_hit.dart';
import '../repositories/monitor_repository.dart';
import 'monitor_fetch_service.dart';

enum MonitorCheckStatus {
  newHits,
  noNewHits,
  failure,
}

class MonitorCheckResult {
  final String sourceId;
  final MonitorCheckStatus status;
  final DateTime checkedAt;
  final int newHitCount;
  final String? errorMessage;

  const MonitorCheckResult({
    required this.sourceId,
    required this.status,
    required this.checkedAt,
    required this.newHitCount,
    required this.errorMessage,
  });
}

class MonitorCheckService {
  final MonitorRepository _repository;
  final MonitorCandidateFetcher _fetcher;

  MonitorCheckService({
    required MonitorRepository repository,
    required MonitorCandidateFetcher fetcher,
  })  : _repository = repository,
        _fetcher = fetcher;

  Future<MonitorCheckResult> checkSource(String sourceId) async {
    final source = _repository.getSource(sourceId);
    if (source == null) {
      throw Exception('Monitor source not found: $sourceId');
    }

    final checkedAt = DateTime.now();
    final fetched = await _fetcher.fetchCandidates(source);
    if (!fetched.isSuccess) {
      await _repository.saveSource(
        source.copyWith(
          lastCheckedAt: checkedAt,
          lastStatus: 'failure',
          updatedAt: checkedAt,
        ),
      );
      return MonitorCheckResult(
        sourceId: sourceId,
        status: MonitorCheckStatus.failure,
        checkedAt: checkedAt,
        newHitCount: 0,
        errorMessage: fetched.errorMessage,
      );
    }

    var newHitCount = 0;
    for (final candidate in fetched.candidates) {
      final matched = _matchedKeywords(source.keywords, candidate);
      if (matched.isEmpty) continue;

      final fingerprint = _fingerprint(
        sourceId: source.id,
        title: candidate.title,
        link: candidate.link,
      );
      if (_repository.hasFingerprint(fingerprint)) continue;

      await _repository.saveHit(
        MonitorHit(
          id: _repository.nextId(),
          sourceId: source.id,
          title: candidate.title,
          link: candidate.link,
          summary: candidate.summary,
          matchedKeywords: matched,
          publishedAt: candidate.publishedAt,
          discoveredAt: checkedAt,
          contentFingerprint: fingerprint,
          notificationSentAt: null,
          createdAt: checkedAt,
        ),
      );
      newHitCount++;
    }

    final status =
        newHitCount > 0 ? MonitorCheckStatus.newHits : MonitorCheckStatus.noNewHits;
    await _repository.saveSource(
      source.copyWith(
        lastCheckedAt: checkedAt,
        lastStatus: status.name,
        updatedAt: checkedAt,
      ),
    );
    return MonitorCheckResult(
      sourceId: sourceId,
      status: status,
      checkedAt: checkedAt,
      newHitCount: newHitCount,
      errorMessage: null,
    );
  }

  List<String> _matchedKeywords(
    List<String> keywords,
    MonitorCandidate candidate,
  ) {
    final haystack = '${candidate.title} ${candidate.summary}'.toLowerCase();
    return keywords
        .map((keyword) => keyword.trim())
        .where((keyword) => keyword.isNotEmpty)
        .where((keyword) => haystack.contains(keyword.toLowerCase()))
        .toList();
  }

  String _fingerprint({
    required String sourceId,
    required String title,
    required String link,
  }) {
    final normalizedLink = link.trim().toLowerCase();
    final normalizedTitle = title.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
    return '$sourceId|$normalizedLink|$normalizedTitle';
  }
}
