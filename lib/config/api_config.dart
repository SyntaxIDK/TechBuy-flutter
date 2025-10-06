class ApiConfig {
  // Azure production URL instead of localhost
  static const String baseUrl = 'https://techbuy-webapp-agbgf2gbgud8apaw.centralindia-01.azurewebsites.net';
  static const String apiVersion = '/api';

  // Full API base URL
  static String get apiBaseUrl => '$baseUrl$apiVersion';

  // Endpoints
  static const String products = '/products';
  static const String categories = '/categories';
  static const String auth = '/auth';
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String profile = '/auth/profile';
  static const String logout = '/auth/logout';

  // Storage endpoints for images
  static String get storageUrl => '$baseUrl/storage';
}
