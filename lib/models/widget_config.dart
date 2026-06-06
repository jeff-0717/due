class WidgetConfig {
  final String id;
  final String countdownId;
  final String style;
  final DateTime updatedAt;

  const WidgetConfig({
    required this.id,
    required this.countdownId,
    required this.style,
    required this.updatedAt,
  });

  WidgetConfig copyWith({
    String? id,
    String? countdownId,
    String? style,
    DateTime? updatedAt,
  }) {
    return WidgetConfig(
      id: id ?? this.id,
      countdownId: countdownId ?? this.countdownId,
      style: style ?? this.style,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'countdownId': countdownId,
        'style': style,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory WidgetConfig.fromJson(Map<String, dynamic> json) => WidgetConfig(
        id: json['id'] as String,
        countdownId: json['countdownId'] as String,
        style: json['style'] as String,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}
