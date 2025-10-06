import 'package:flutter/foundation.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isAuthenticated = false;
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize auth state on app start
  Future<void> initializeAuth() async {
    _setLoading(true);
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        // Verify token is still valid
        final isValid = await _authService.verifyToken();
        if (isValid) {
          final user = await _authService.getStoredUser();
          if (user != null) {
            _currentUser = user;
            _isAuthenticated = true;
          }
        } else {
          // Token is invalid, clear stored data
          await _authService.logout();
        }
      }
    } catch (e) {
      _setError('Failed to initialize authentication');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final authResponse = await _authService.login(
        email: email,
        password: password,
      );

      _isAuthenticated = true;
      _currentUser = authResponse.user;
      notifyListeners();
      return true;
    } catch (e) {
      if (e is ApiError) {
        _setError(e.displayMessage);
      } else {
        _setError('Login failed. Please try again.');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String name, String email, String password, String passwordConfirmation) async {
    _setLoading(true);
    _clearError();

    try {
      final authResponse = await _authService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      _isAuthenticated = true;
      _currentUser = authResponse.user;
      notifyListeners();
      return true;
    } catch (e) {
      if (e is ApiError) {
        _setError(e.displayMessage);
      } else {
        _setError('Registration failed. Please try again.');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(String name, String email) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedUser = await _authService.updateProfile(
        name: name,
        email: email,
      );

      _currentUser = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      if (e is ApiError) {
        _setError(e.displayMessage);
      } else {
        _setError('Profile update failed. Please try again.');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword, String newPasswordConfirmation) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );

      return true;
    } catch (e) {
      if (e is ApiError) {
        _setError(e.displayMessage);
      } else {
        _setError('Password change failed. Please try again.');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
    } catch (e) {
      // Continue with logout even if API call fails
      print('Logout error: $e');
    } finally {
      _isAuthenticated = false;
      _currentUser = null;
      _clearError();
      _setLoading(false);
    }
  }

  Future<void> logoutAll() async {
    _setLoading(true);
    try {
      await _authService.logoutAll();
    } catch (e) {
      print('Logout all error: $e');
    } finally {
      _isAuthenticated = false;
      _currentUser = null;
      _clearError();
      _setLoading(false);
    }
  }

  Future<bool> deleteAccount() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.deleteAccount();
      _isAuthenticated = false;
      _currentUser = null;
      notifyListeners();
      return true;
    } catch (e) {
      if (e is ApiError) {
        _setError(e.displayMessage);
      } else {
        _setError('Account deletion failed. Please try again.');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
