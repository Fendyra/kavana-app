// File: lib/data/models/agenda_model.dart
class AgendaModel {
  final int id;
  final int? userId;
  final String title;
  final String category;
  final DateTime startEvent; // Harusnya tidak null setelah fallback
  final DateTime endEvent;   // Harusnya tidak null setelah fallback
  final String? description;
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
    this.locationName,
    this.latitude,
    this.longitude,
  });

  factory AgendaModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse DateTime strings
    DateTime _parseDateTimeFallback(String? dateString) {
      if (dateString != null && dateString.isNotEmpty) {
        try {
          // DateTime.parse handles ISO 8601 formats including offsets
          return DateTime.parse(dateString);
        } catch (e) {
          print('Error parsing date string "$dateString": $e');
          // Fallback if parsing fails for any reason
          return DateTime(1970); // Return epoch time as fallback
        }
      }
      // Return epoch time if the string is null or empty
      print('Warning: Received null or empty date string, using fallback.');
      return DateTime(1970);
    }

    // Helper function to safely parse double from dynamic
    double? _parseDouble(dynamic value) {
        if (value == null) return null;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) return double.tryParse(value);
        return null; // Return null if conversion fails
    }


    return AgendaModel(
      // Provide default values for required fields if they might be null from API
      id: json['id'] as int? ?? 0, // Default to 0 if null
      userId: json['user_id'] as int?,
      title: json['title'] as String? ?? 'No Title', // Default title
      category: json['category'] as String? ?? 'Uncategorized', // Default category
      startEvent: _parseDateTimeFallback(json['start_event'] as String?),
      endEvent: _parseDateTimeFallback(json['end_event'] as String?),
      description: json['description'] as String?, // Can be null
      locationName: json['location_name'] as String?, // Can be null
      latitude: _parseDouble(json['latitude']), // Use safe parsing
      longitude: _parseDouble(json['longitude']), // Use safe parsing
    );
  }

  // toJsonRequest remains the same as before, sending location data
  Map<String, String> toJsonRequest() {
    return {
      'id': id.toString(), // Usually not needed for add, but good for update
      'user_id': userId.toString(),
      'title': title,
      'category': category,
      // Format DateTime to ISO8601 string for sending
      // toIso8601String() produces UTC format (e.g., 2025-10-30T03:15:00.123Z)
      // If backend expects local time string 'YYYY-MM-DD HH:MM:SS', format manually
      'start_event': startEvent.toIso8601String(),
      'end_event': endEvent.toIso8601String(),
      'description': description ?? '', // Send empty string if null
      'location_name': locationName ?? '',
      'latitude': latitude?.toString() ?? '',
      'longitude': longitude?.toString() ?? '',
    };
  }
}