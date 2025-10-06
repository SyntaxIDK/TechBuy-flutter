import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/auth_models.dart';
import '../config/api_config.dart';
import '../services/http_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final HttpService _httpService = HttpService();
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Using Azure production URL instead of localhost
  String get _baseUrl => ApiConfig.apiBaseUrl;

  // Register a new user
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _httpService.post(ApiConfig.register, {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

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
      final response = await _httpService.post(ApiConfig.login, {
        'email': email,
        'password': password,
      });

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

      _httpService.setToken(token);
      final response = await _httpService.get(ApiConfig.profile);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return User.fromJson(data['data']);
      } else {
        throw ApiError.fromJson(data);
      }
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Error fetching profile: ${e.toString()}');
    }
  }

  // Update user profile
  Future<User> updateProfile({
    required String name,
    String? phone,
    String? currentPassword,
    String? newPassword,
    String? newPasswordConfirmation,
  }) async {
    try {
      final token = await getStoredToken();
      if (token == null) {
        throw ApiError(message: 'No authentication token found');
      }

      _httpService.setToken(token);

      final data = <String, dynamic>{
        'name': name,
        if (phone != null) 'phone': phone,
        if (currentPassword != null) 'current_password': currentPassword,
        if (newPassword != null) 'new_password': newPassword,
        if (newPasswordConfirmation != null) 'new_password_confirmation': newPasswordConfirmation,
      };

      final response = await _httpService.put(ApiConfig.profile, data);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final user = User.fromJson(responseData['data']);
        await _saveUserData(user);
        return user;
      } else {
        throw ApiError.fromJson(responseData);
      }
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: 'Error updating profile: ${e.toString()}');
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      final token = await getStoredToken();
      if (token != null) {
        _httpService.setToken(token);
        await _httpService.post(ApiConfig.logout, {});
      }
    } catch (e) {
      debugPrint('Logout API call failed: $e');
      // Continue with local logout even if API call fails
    } finally {
      await _clearAuthData();
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getStoredToken();
    return token != null && token.isNotEmpty;
  }

  // Get stored token
  Future<String?> getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      debugPrint('Error getting stored token: $e');
      return null;
    }
  }

  // Get stored user
  Future<User?> getStoredUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        return User.fromJson(jsonDecode(userJson));
      }
      return null;
    } catch (e) {
      debugPrint('Error getting stored user: $e');
      return null;
    }
  }

  // Save authentication data
  Future<void> _saveAuthData(String token, User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      _httpService.setToken(token);
    } catch (e) {
      debugPrint('Error saving auth data: $e');
    }
  }

  // Save user data only
  Future<void> _saveUserData(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }

  // Clear authentication data
  Future<void> _clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      _httpService.clearToken();
    } catch (e) {
      debugPrint('Error clearing auth data: $e');
    }
  }
}
