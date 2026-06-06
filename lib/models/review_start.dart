class ReviewStart {
  final String id;
  final DateTime startDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReviewStart({
    required this.id,
    required this.startDate,
    required this.createdAt,
    required this.updatedAt,
  });

  ReviewStart copyWith({
    String? id,
    DateTime? startDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewStart(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'startDate': startDate.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ReviewStart.fromJson(Map<String, dynamic> json) => ReviewStart(
        id: json['id'] as String,
        startDate: DateTime.parse(json['startDate'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}
