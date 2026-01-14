import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get googlePlacesApiKey => dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
  static const String googlePlacesBaseUrl = 'https://places.googleapis.com/v1/places:searchText';
  
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? ''; 
  
  static const String geminiModelName = 'gemini-2.5-flash';
}
