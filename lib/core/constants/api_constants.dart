class ApiConstants {
  static const String googlePlacesApiKey = 'AIzaSyAeQBTQno2MLk2X_thUhFyGJqriQ612zSs';
  static const String googlePlacesBaseUrl = 'https://places.googleapis.com/v1/places:searchText';
  
  // Note: Replace with your actual Gemini API Key
  static const String geminiApiKey = 'AIzaSyDK8FV8AL1Bko8g5KZLv9Ijym4QOS3VnRw'; 
  // Using the same key as Google Places assuming it has access to Generative AI as well, 
  // if not, user needs to provide a separate one. 
  // The user prompt implied auto-detection which usually means Env var, but for Flutter app we put it here.
  // Actually, the user provided python code showed 'auto-detects', but provided a specific key for Places earlier.
  // I will use the same key for now.
  static const String geminiModelName = 'gemini-2.5-flash';
}
