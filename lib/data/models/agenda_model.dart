class AgendaModel {
  final int id;
  final int? userId;
  final String title;
  final String category;
  final DateTime startEvent;
  final DateTime endEvent;
  final String? description;
  AgendaModel({
    required this.id,
    this.userId,
    required this.title,
    required this.category,
    required this.startEvent,
    required this.endEvent,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'user_id': userId,
      'title': title,
      'category': category,
      'start_event': startEvent.toIso8601String(),
      'end_event': endEvent.toIso8601String(),
      'description': description,
    };
  }

  factory AgendaModel.fromJson(Map<String, dynamic> json) {
    return AgendaModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      category: json['category'],
      startEvent: DateTime.parse(json['start_event']),
      endEvent: DateTime.parse(json['end_event']),
      description: json['description'],
    );
  }

  Map<String, String> toJsonRequest() {
    return {
      'id': id.toString(),
      'user_id': userId.toString(),
      'title': title,
      'category': category,
      'start_event': startEvent.toIso8601String(),
      'end_event': endEvent.toIso8601String(),
      'description': description.toString(),
    };
  }
}
