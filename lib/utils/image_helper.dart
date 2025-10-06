import '../config/api_config.dart';

class ImageHelper {
  static String getProductImageUrl(String imagePath) {
    // If it's already a full URL, return as is
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    // Remove 'products/' prefix if present as it's already in the path
    final cleanPath = imagePath.startsWith('products/')
        ? imagePath
        : 'products/$imagePath';

    return '${ApiConfig.storageUrl}/$cleanPath';
  }

  static String getCategoryImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';

    // If it's already a full URL, return as is
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    final cleanPath = imagePath.startsWith('categories/')
        ? imagePath
        : 'categories/$imagePath';

    return '${ApiConfig.storageUrl}/$cleanPath';
  }

  static String getUserAvatarUrl(String? avatarPath) {
    if (avatarPath == null || avatarPath.isEmpty) return '';

    // If it's already a full URL, return as is
    if (avatarPath.startsWith('http')) {
      return avatarPath;
    }

    final cleanPath = avatarPath.startsWith('profile-photos/')
        ? avatarPath
        : 'profile-photos/$avatarPath';

    return '${ApiConfig.storageUrl}/$cleanPath';
  }
}
