class User {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String profilePhotoUrl;
  final bool twoFactorEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.profilePhotoUrl,
    required this.twoFactorEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      emailVerifiedAt: json['email_verified_at'],
      profilePhotoUrl: json['profile_photo_url'],
      twoFactorEnabled: json['two_factor_enabled'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'profile_photo_url': profilePhotoUrl,
      'two_factor_enabled': twoFactorEnabled,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class AuthResponse {
  final String message;
  final User user;
  final String token;
  final String tokenType;

  AuthResponse({
    required this.message,
    required this.user,
    required this.token,
    required this.tokenType,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'],
      user: User.fromJson(json['user']),
      token: json['token'],
      tokenType: json['token_type'],
    );
  }
}

class ApiError {
  final String message;
  final Map<String, List<String>>? errors;

  ApiError({
    required this.message,
    this.errors,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'],
      errors: json['errors'] != null
          ? Map<String, List<String>>.from(
              json['errors'].map((key, value) => MapEntry(key, List<String>.from(value))))
          : null,
    );
  }

  String get displayMessage {
    if (errors != null && errors!.isNotEmpty) {
      // Return the first error message
      return errors!.values.first.first;
    }
    return message;
  }
}
