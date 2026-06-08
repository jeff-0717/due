class StudySession {
  final String id;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSeconds;
  final int plannedSeconds;
  final DateTime createdAt;

  const StudySession({
    required this.id,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    required this.plannedSeconds,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt.toIso8601String(),
        'durationSeconds': durationSeconds,
        'plannedSeconds': plannedSeconds,
        'createdAt': createdAt.toIso8601String(),
      };

  factory StudySession.fromJson(Map<String, dynamic> json) => StudySession(
        id: json['id'] as String,
        startedAt: DateTime.parse(json['startedAt'] as String),
        endedAt: DateTime.parse(json['endedAt'] as String),
        durationSeconds: json['durationSeconds'] as int,
        plannedSeconds: json['plannedSeconds'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
