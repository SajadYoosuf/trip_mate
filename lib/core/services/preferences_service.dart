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
  
  Future<void> saveUserObj(String name, String email) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userNameKey, name);
      await prefs.setString(_userEmailKey, email);
  }
  
  Future<Map<String, String>?> getUserObj() async {
       final prefs = await SharedPreferences.getInstance();
       final name = prefs.getString(_userNameKey);
       final email = prefs.getString(_userEmailKey);
       if (name != null && email != null) {
           return {'name': name, 'email': email};
       }
       return null;
  }

  Future<void> clearUser() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_isLoggedInKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_userEmailKey);
  }
}
