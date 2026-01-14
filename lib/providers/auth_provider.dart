import 'package:flutter/foundation.dart';
import 'package:temporal_zodiac/services/preferences_service.dart';
import 'package:temporal_zodiac/models/user.dart';
import 'package:temporal_zodiac/services/auth/auth_repository.dart';

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
    try {
      final user = await _repository.getCurrentUser();
      
      _currentUser = user;
      
      // Update preferences if needed, or clear if user is null
      if (user != null) {
         await _preferencesService.setLoggedIn(true);
         await _preferencesService.saveUserObj(user.name, user.email, user.photoUrl);
      } else {
         await _preferencesService.setLoggedIn(false);
         await _preferencesService.clearUser();
      }
    } catch (e) {
      // If network calls fail, try to restore from local storage
      final isLoggedIn = await _preferencesService.isLoggedIn();
      if (isLoggedIn) {
        final userData = await _preferencesService.getUserObj();
        if (userData != null) {
          _currentUser = User(
            id: 'persisted',
            name: userData['name'] ?? '',
            email: userData['email'] ?? '',
            photoUrl: userData['photoUrl'],
          );
        }
      } else {
        _currentUser = null;
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
      await _preferencesService.saveUserObj(user.name, user.email, user.photoUrl);
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
      await _preferencesService.saveUserObj(user.name, user.email, user.photoUrl);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.forgotPassword(email);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({required String name, required String phone, String? photoUrl}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_currentUser == null) throw Exception('No user logged in');
      
      final updatedUser = User(
        id: _currentUser!.id,
        name: name,
        email: _currentUser!.email,
        phone: phone,
        photoUrl: photoUrl ?? _currentUser!.photoUrl,
      );
      
      final result = await _repository.updateProfile(updatedUser);
      _currentUser = result;
      await _preferencesService.saveUserObj(result.name, result.email, result.photoUrl);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> uploadProfileImage(String filePath) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      return await _repository.uploadProfileImage(filePath);
    } catch (e) {
      _error = e.toString();
      rethrow;
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
