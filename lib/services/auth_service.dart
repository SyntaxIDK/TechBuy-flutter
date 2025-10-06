import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/auth_models.dart';
import '../constants/api_constants.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Get the appropriate base URL based on platform
  String get _baseUrl {
    if (kIsWeb) {
      // For web platform, use localhost
      return 'http://127.0.0.1:8000/api';
    } else {
      // For mobile platforms, use the mobile-specific URLs
      return ApiConstants.baseUrl;
    }
  }

  // Register a new user
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}/auth/register'),
        headers: ApiConstants.headers,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(data);
        await _saveAuthData(authResponse.token, authResponse.user);
        return authResponse;
      } else {
        throw ApiError.fromJson(data);
      }
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Network error: ${e.toString()}');
    }
  }

  // Login user
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}/auth/login'),
        headers: ApiConstants.headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(data);
        await _saveAuthData(authResponse.token, authResponse.user);
        return authResponse;
      } else {
        throw ApiError.fromJson(data);
      }
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Network error: ${e.toString()}');
    }
  }

  // Get user profile
  Future<User> getProfile() async {
    try {
      final token = await getStoredToken();
      if (token == null) {
        throw ApiError(message: 'No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${_baseUrl}/auth/profile'),
        headers: ApiConstants.authHeaders(token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final user = User.fromJson(data['user']);
        await _saveUserData(user);
        return user;
      } else {
        throw ApiError.fromJson(data);
      }
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Network error: ${e.toString()}');
    }
  }

  // Update user profile
  Future<User> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      final token = await getStoredToken();
      if (token == null) {
        throw ApiError(message: 'No authentication token found');
      }

      final response = await http.put(
        Uri.parse('${_baseUrl}/auth/profile'),
        headers: ApiConstants.authHeaders(token),
        body: jsonEncode({
          'name': name,
          'email': email,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final user = User.fromJson(data['user']);
        await _saveUserData(user);
        return user;
      } else {
        throw ApiError.fromJson(data);
      }
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Network error: ${e.toString()}');
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final token = await getStoredToken();
      if (token == null) {
        throw ApiError(message: 'No authentication token found');
      }

      final response = await http.put(
        Uri.parse('${_baseUrl}/auth/change-password'),
        headers: ApiConstants.authHeaders(token),
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw ApiError.fromJson(data);
      }
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Network error: ${e.toString()}');
    }
  }

  // Logout current device
  Future<void> logout() async {
    try {
      final token = await getStoredToken();
      if (token != null) {
        await http.post(
          Uri.parse('${_baseUrl}/auth/logout'),
          headers: ApiConstants.authHeaders(token),
        );
      }
    } catch (e) {
      // Even if the API call fails, we should still clear local data
      print('Logout API call failed: $e');
    } finally {
      await _clearAuthData();
    }
  }

  // Logout all devices
  Future<void> logoutAll() async {
    try {
      final token = await getStoredToken();
      if (token != null) {
        await http.post(
          Uri.parse('${_baseUrl}/auth/logout-all'),
          headers: ApiConstants.authHeaders(token),
        );
      }
    } catch (e) {
      print('Logout all API call failed: $e');
    } finally {
      await _clearAuthData();
    }
  }

  // Verify token
  Future<bool> verifyToken() async {
    try {
      final token = await getStoredToken();
      if (token == null) return false;

      final response = await http.get(
        Uri.parse('${_baseUrl}/auth/verify-token'),
        headers: ApiConstants.authHeaders(token),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final token = await getStoredToken();
      if (token == null) {
        throw ApiError(message: 'No authentication token found');
      }

      final response = await http.delete(
        Uri.parse('${_baseUrl}/auth/delete-account'),
        headers: ApiConstants.authHeaders(token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _clearAuthData();
      } else {
        throw ApiError.fromJson(data);
      }
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Network error: ${e.toString()}');
    }
  }

  // Get stored authentication token
  Future<String?> getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(StorageKeys.authToken);
    } catch (e) {
      return null;
    }
  }

  // Get stored user data
  Future<User?> getStoredUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(StorageKeys.userData);
      if (userJson != null) {
        return User.fromJson(jsonDecode(userJson));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Save authentication data
  Future<void> _saveAuthData(String token, User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.authToken, token);
      await prefs.setString(StorageKeys.userData, jsonEncode(user.toJson()));
      await prefs.setBool(StorageKeys.isLoggedIn, true);
    } catch (e) {
      print('Error saving auth data: $e');
    }
  }

  // Save user data
  Future<void> _saveUserData(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.userData, jsonEncode(user.toJson()));
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  // Clear authentication data
  Future<void> _clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageKeys.authToken);
      await prefs.remove(StorageKeys.userData);
      await prefs.setBool(StorageKeys.isLoggedIn, false);
    } catch (e) {
      print('Error clearing auth data: $e');
    }
  }
}
