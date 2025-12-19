import 'package:temporal_zodiac/features/auth/domain/entities/user.dart';
import 'package:temporal_zodiac/features/auth/domain/repositories/auth_repository.dart';
import 'package:uuid/uuid.dart';

class MockAuthRepositoryImpl implements AuthRepository {
  @override
  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    // Mock successful login
    return User(
      id: const Uuid().v4(),
      name: 'Test User',
      email: email,
      phone: '1234567890',
    );
  }

  @override
  Future<User> signUp(String name, String email, String password, String phone) async {
    await Future.delayed(const Duration(seconds: 1));
    return User(
      id: const Uuid().v4(),
      name: name,
      email: email,
      phone: phone,
    );
  }

  @override
  Future<void> forgotPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    // Mock email sent
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
