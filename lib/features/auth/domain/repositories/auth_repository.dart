import 'package:temporal_zodiac/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> signUp(String name, String email, String password, String phone);
  Future<void> forgotPassword(String email);
  Future<void> logout();
}
