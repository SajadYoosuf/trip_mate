import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _isOnboardingCompletedKey = 'isOnboardingCompleted';
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userNameKey = 'userName';
  static const String _userEmailKey = 'userEmail';

  Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isOnboardingCompletedKey, true);
  }

  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isOnboardingCompletedKey) ?? false;
  }

  Future<void> setLoggedIn(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }
  
  static const String _userPhotoUrlKey = 'userPhotoUrl';

  Future<void> saveUserObj(String name, String email, String? photoUrl) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userNameKey, name);
      await prefs.setString(_userEmailKey, email);
      if (photoUrl != null) {
        await prefs.setString(_userPhotoUrlKey, photoUrl);
      } else {
        await prefs.remove(_userPhotoUrlKey);
      }
  }
  
  Future<Map<String, String>?> getUserObj() async {
       final prefs = await SharedPreferences.getInstance();
       final name = prefs.getString(_userNameKey);
       final email = prefs.getString(_userEmailKey);
       final photoUrl = prefs.getString(_userPhotoUrlKey);
       if (name != null && email != null) {
           return {
             'name': name, 
             'email': email,
             if (photoUrl != null) 'photoUrl': photoUrl,
           };
       }
       return null;
  }

  Future<void> clearUser() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_isLoggedInKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_userEmailKey);
  }

  static const String _chatHistoryKey = 'chatHistory';

  Future<void> saveChatMessages(List<Map<String, dynamic>> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = messages.map((msg) => jsonEncode(msg)).toList();
    await prefs.setStringList(_chatHistoryKey, jsonList);
  }

  Future<List<Map<String, dynamic>>> getChatMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_chatHistoryKey);
    
    if (jsonList == null) return [];

    return jsonList.map((jsonStr) => jsonDecode(jsonStr) as Map<String, dynamic>).toList();
  }
}
