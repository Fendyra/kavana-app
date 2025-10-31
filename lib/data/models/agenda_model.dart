class AgendaModel {
  final int id;
  final int? userId;
  final String title;
  final String category;
  final DateTime startEvent;
  final DateTime endEvent;
  final String? description;
  final String? timeZone;
  final String? locationName; 
  final double? latitude; 
  final double? longitude; 
  
  AgendaModel({
    required this.id,
    this.userId,
    required this.title,
    required this.category,
    required this.startEvent,
    required this.endEvent,
    this.description,
    this.timeZone,
    this.locationName, 
    this.latitude, 
    this.longitude, 
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
      'location_name': locationName, 
      'latitude': latitude, 
      'longitude': longitude, 
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
      timeZone: json['time_zone'],
      locationName: json['location_name'], 
      // Konversi latitude/longitude dari API (yang mungkin String atau double)
      latitude: json['latitude'] == null ? null : double.tryParse(json['latitude'].toString()), // <--- TAMBAHKAN BARIS INI
      longitude: json['longitude'] == null ? null : double.tryParse(json['longitude'].toString()), // <--- TAMBAHKAN BARIS INI
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
      'time_zone': timeZone.toString(),
      'location_name': locationName ?? '', 
      'latitude': latitude?.toString() ?? '', 
      'longitude': longitude?.toString() ?? '', 
    };
  }
}