class MonitorHit {
  final String id;
  final String sourceId;
  final String title;
  final String link;
  final String summary;
  final List<String> matchedKeywords;
  final DateTime? publishedAt;
  final DateTime discoveredAt;
  final String contentFingerprint;
  final DateTime? notificationSentAt;
  final DateTime createdAt;

  const MonitorHit({
    required this.id,
    required this.sourceId,
    required this.title,
    required this.link,
    required this.summary,
    required this.matchedKeywords,
    required this.publishedAt,
    required this.discoveredAt,
    required this.contentFingerprint,
    required this.notificationSentAt,
    required this.createdAt,
  });

  MonitorHit copyWith({DateTime? notificationSentAt}) {
    return MonitorHit(
      id: id,
      sourceId: sourceId,
      title: title,
      link: link,
      summary: summary,
      matchedKeywords: matchedKeywords,
      publishedAt: publishedAt,
      discoveredAt: discoveredAt,
      contentFingerprint: contentFingerprint,
      notificationSentAt: notificationSentAt ?? this.notificationSentAt,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceId': sourceId,
        'title': title,
        'link': link,
        'summary': summary,
        'matchedKeywords': matchedKeywords,
        'publishedAt': publishedAt?.toIso8601String(),
        'discoveredAt': discoveredAt.toIso8601String(),
        'contentFingerprint': contentFingerprint,
        'notificationSentAt': notificationSentAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory MonitorHit.fromJson(Map<String, dynamic> json) {
    return MonitorHit(
      id: json['id'] as String,
      sourceId: json['sourceId'] as String,
      title: json['title'] as String,
      link: json['link'] as String,
      summary: json['summary'] as String,
      matchedKeywords: (json['matchedKeywords'] as List<dynamic>).cast<String>(),
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'] as String)
          : null,
      discoveredAt: DateTime.parse(json['discoveredAt'] as String),
      contentFingerprint: json['contentFingerprint'] as String,
      notificationSentAt: json['notificationSentAt'] != null
          ? DateTime.parse(json['notificationSentAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
