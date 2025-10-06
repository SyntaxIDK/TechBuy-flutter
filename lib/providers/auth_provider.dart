import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  String? get currentUser => _currentUser;

  Future<bool> login(String email, String password) async {
    // Simulate login delay
    await Future.delayed(const Duration(seconds: 1));

    // For demo purposes, accept any non-empty credentials
    if (email.isNotEmpty && password.isNotEmpty) {
      _isAuthenticated = true;
      _currentUser = email;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    // Simulate registration delay
    await Future.delayed(const Duration(seconds: 1));

    // For demo purposes, accept any non-empty credentials
    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      _isAuthenticated = true;
      _currentUser = email;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }
}
