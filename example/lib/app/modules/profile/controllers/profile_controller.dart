import 'package:getxify/getxify.dart';

import '../../../../services/auth_service.dart';

/// Controller for the profile screen
/// Handles user profile-related logic and state
class ProfileController extends GetxController {
  /// Get the authentication service
  AuthService get authService => AuthService.to;

  /// Observable for user name
  final userName = 'John Doe'.obs;

  /// Observable for user email
  final userEmail = 'john.doe@example.com'.obs;

  /// Logout the user
  void logout() {
    authService.logout();
    Get.offNamedUntil('/login', (route) => false);
  }
}
