import 'package:getxify/getxify.dart';

import '../../../../services/auth_service.dart';

/// Controller for the login screen
/// Handles login-related logic and state
class LoginController extends GetxController {
  /// Observable for loading state during login
  final isLoading = false.obs;

  /// Get the authentication service
  AuthService get authService => AuthService.to;

  /// Perform login operation
  /// In a real app, this would make an API call
  Future<void> login() async {
    isLoading.value = true;
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    authService.login();
    isLoading.value = false;
  }
}
