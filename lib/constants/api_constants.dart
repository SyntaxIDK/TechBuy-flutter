class ApiConstants {
  // Base URL for your Laravel API
  // For Android emulator: use 10.0.2.2
  // For iOS simulator: use 127.0.0.1 or localhost
  // For physical device: use your computer's IP address
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Alternative URLs for different platforms
  static const String baseUrlIOS = 'http://127.0.0.1:8000/api';
  static const String baseUrlPhysicalDevice = 'http://YOUR_IP_ADDRESS:8000/api'; // Replace with your IP

  // Auth endpoints
  static const String authBaseUrl = '$baseUrl/auth';
  static const String register = '$authBaseUrl/register';
  static const String login = '$authBaseUrl/login';
  static const String logout = '$authBaseUrl/logout';
  static const String logoutAll = '$authBaseUrl/logout-all';
  static const String profile = '$authBaseUrl/profile';
  static const String changePassword = '$authBaseUrl/change-password';
  static const String refreshToken = '$authBaseUrl/refresh-token';
  static const String verifyToken = '$authBaseUrl/verify-token';
  static const String deleteAccount = '$authBaseUrl/delete-account';

  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) {
    return {
      ...headers,
      'Authorization': 'Bearer $token',
    };
  }
}

// Storage keys for SharedPreferences
class StorageKeys {
  static const String authToken = 'auth_token';
  static const String userData = 'user_data';
  static const String isLoggedIn = 'is_logged_in';
}
