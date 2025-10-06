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
      final isLoggedIn = await _authService.isAuthenticated();
      if (isLoggedIn) {
        // Try to get the user profile to verify token is still valid
        try {
          final user = await _authService.getProfile();
          _currentUser = user;
          _isAuthenticated = true;
        } catch (e) {
          // Token is invalid, clear stored data
          await _authService.logout();
          _isAuthenticated = false;
          _currentUser = null;
        }
      }
    } catch (e) {
      _setError('Failed to initialize authentication');
      debugPrint('Auth initialization error: $e');
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

  Future<bool> updateProfile(String name, {String? phone}) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedUser = await _authService.updateProfile(
        name: name,
        phone: phone,
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
      await _authService.updateProfile(
        name: _currentUser?.name ?? '',
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
      debugPrint('Logout error: $e');
    } finally {
      _isAuthenticated = false;
      _currentUser = null;
      _clearError();
      _setLoading(false);
    }
  }

  // Note: Azure API doesn't have logoutAll endpoint, so we'll use regular logout
  Future<void> logoutAll() async {
    await logout();
  }

  // Note: Azure API doesn't have deleteAccount endpoint, so we'll simulate it
  Future<bool> deleteAccount() async {
    _setLoading(true);
    _clearError();

    try {
      // For now, we'll just logout since the API doesn't support account deletion
      // You can implement this on the Laravel side if needed
      await logout();
      _setError('Account deletion is not currently supported. Please contact support.');
      return false;
    } catch (e) {
      _setError('Account deletion failed. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helper method to refresh user data
  Future<void> refreshUser() async {
    if (!_isAuthenticated) return;

    try {
      final user = await _authService.getProfile();
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to refresh user data: $e');
      // If refresh fails, user might be logged out
      await logout();
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

  // Public method to clear errors
  void clearError() {
    _clearError();
  }
}
