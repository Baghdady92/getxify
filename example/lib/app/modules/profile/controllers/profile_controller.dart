import 'package:getxify/getxify.dart';

import '../../../../services/auth_service.dart';

/// Controller for the profile screen
/// Handles user profile-related logic and state
class ProfileController extends GetxController {
  /// Get the authentication service
  AuthService get authService => AuthService.to;

  /// Observable for user name
  final userName = ''.obs;

  /// Observable for user email
  final userEmail = ''.obs;

  /// Load user profile data
  /// In a real app, this would fetch from an API
  void loadUserProfile() {
    // Demo data - in production, fetch from API
    userName.value = 'John Doe';
    userEmail.value = 'john.doe@getxify.dev';
  }

  @override
  void onReady() {
    super.onReady();
    loadUserProfile();
  }

  /// Logout the user
  void logout() {
    authService.logout();
    Get.offNamedUntil('/login', (route) => false);
  }
}
