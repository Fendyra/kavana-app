class MoodModel {
  final int? id;
  final int? userId;
  final int level;
  final DateTime createdAt;

  MoodModel({
    this.id,
    this.userId,
    required this.level,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'user_id': userId,
      'level': level,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory MoodModel.fromJson(Map<String, dynamic> json) {
    return MoodModel(
      id: json['id'],
      userId: json['user_id'],
      level: json['level'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, String> toJsonRequest() {
    return {
      'id': id.toString(),
      'user_id': userId.toString(),
      'level': level.toString(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
