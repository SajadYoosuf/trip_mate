import 'package:flutter/foundation.dart';
import 'package:temporal_zodiac/core/services/preferences_service.dart';
import 'package:temporal_zodiac/features/auth/domain/entities/user.dart';
import 'package:temporal_zodiac/features/auth/domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  final PreferencesService _preferencesService;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider({
    required AuthRepository repository,
    required PreferencesService preferencesService,
  })  : _repository = repository,
        _preferencesService = preferencesService;

  Future<void> checkAuthStatus() async {
    final isLoggedIn = await _preferencesService.isLoggedIn();
    if (isLoggedIn) {
      final userData = await _preferencesService.getUserObj();
      if (userData != null) {
        // In a real app, we might fetch the user profile from ID or token.
        // For now, reconstruct from preferences.
        _currentUser = User(
          id: 'persisted',
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
        );
      }
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _repository.login(email, password);
      _currentUser = user;
      await _preferencesService.setLoggedIn(true);
      await _preferencesService.saveUserObj(user.name, user.email);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp(String name, String email, String password, String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _repository.signUp(name, email, password, phone);
      _currentUser = user;
      await _preferencesService.setLoggedIn(true);
      await _preferencesService.saveUserObj(user.name, user.email);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _currentUser = null;
    await _preferencesService.clearUser();
    notifyListeners();
  }
}
