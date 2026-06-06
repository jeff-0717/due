enum MonitorSourceType {
  rss,
  webPage,
}

class MonitorSource {
  final String id;
  final String schoolName;
  final String sourceName;
  final String url;
  final MonitorSourceType sourceType;
  final List<String> keywords;
  final bool isEnabled;
  final DateTime? lastCheckedAt;
  final String? lastStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MonitorSource({
    required this.id,
    required this.schoolName,
    required this.sourceName,
    required this.url,
    required this.sourceType,
    required this.keywords,
    required this.isEnabled,
    required this.lastCheckedAt,
    required this.lastStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  MonitorSource copyWith({
    String? id,
    String? schoolName,
    String? sourceName,
    String? url,
    MonitorSourceType? sourceType,
    List<String>? keywords,
    bool? isEnabled,
    DateTime? lastCheckedAt,
    String? lastStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MonitorSource(
      id: id ?? this.id,
      schoolName: schoolName ?? this.schoolName,
      sourceName: sourceName ?? this.sourceName,
      url: url ?? this.url,
      sourceType: sourceType ?? this.sourceType,
      keywords: keywords ?? this.keywords,
      isEnabled: isEnabled ?? this.isEnabled,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      lastStatus: lastStatus ?? this.lastStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'schoolName': schoolName,
        'sourceName': sourceName,
        'url': url,
        'sourceType': sourceType.name,
        'keywords': keywords,
        'isEnabled': isEnabled,
        'lastCheckedAt': lastCheckedAt?.toIso8601String(),
        'lastStatus': lastStatus,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory MonitorSource.fromJson(Map<String, dynamic> json) {
    return MonitorSource(
      id: json['id'] as String,
      schoolName: json['schoolName'] as String,
      sourceName: json['sourceName'] as String? ?? '',
      url: json['url'] as String,
      sourceType: MonitorSourceType.values.firstWhere(
        (type) => type.name == json['sourceType'],
        orElse: () => MonitorSourceType.webPage,
      ),
      keywords: (json['keywords'] as List<dynamic>).cast<String>(),
      isEnabled: json['isEnabled'] as bool? ?? true,
      lastCheckedAt: json['lastCheckedAt'] != null
          ? DateTime.parse(json['lastCheckedAt'] as String)
          : null,
      lastStatus: json['lastStatus'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
