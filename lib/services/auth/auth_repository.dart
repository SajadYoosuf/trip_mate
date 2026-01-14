import 'package:temporal_zodiac/models/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> signUp(String name, String email, String password, String phone);
  Future<void> forgotPassword(String email);
  Future<User> updateProfile(User user);
  Future<String> uploadProfileImage(String filePath);
  Future<void> logout();
  Future<User?> getCurrentUser();
}
