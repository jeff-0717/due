import 'dart:ui' show Color;

enum RepeatType {
  once,
  yearly,
}

class Countdown {
  final String id;
  final String title;
  final DateTime targetDate;
  final RepeatType repeatType;
  final String color;
  final String icon;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Countdown({
    required this.id,
    required this.title,
    required this.targetDate,
    required this.repeatType,
    required this.color,
    required this.icon,
    required this.createdAt,
    required this.updatedAt,
  });

  Color get displayColor => Color(int.parse(color.replaceFirst('#', '0xFF')));

  Countdown copyWith({
    String? id,
    String? title,
    DateTime? targetDate,
    RepeatType? repeatType,
    String? color,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Countdown(
      id: id ?? this.id,
      title: title ?? this.title,
      targetDate: targetDate ?? this.targetDate,
      repeatType: repeatType ?? this.repeatType,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'targetDate': targetDate.toIso8601String(),
        'repeatType': repeatType.name,
        'color': color,
        'icon': icon,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Countdown.fromJson(Map<String, dynamic> json) => Countdown(
        id: json['id'] as String,
        title: json['title'] as String,
        targetDate: DateTime.parse(json['targetDate'] as String),
        repeatType: RepeatType.values.firstWhere(
          (e) => e.name == json['repeatType'],
        ),
        color: json['color'] as String,
        icon: json['icon'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}
