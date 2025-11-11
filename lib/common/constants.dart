import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  static const agendaCategories = ['Learn', 'Travel', 'Food & Drink', 'Sport', 'Family', 'Work'];
  
  // Use API key from .env file
  static String get googleAIAPIKey => dotenv.env['GOOGLE_AI_API_KEY'] ?? '';
}
