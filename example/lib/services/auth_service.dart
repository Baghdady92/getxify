import 'package:getxify/getxify.dart';

/// Authentication service
/// Manages user authentication state across the application
class AuthService extends GetxService {
  static AuthService get to => Get.find();

  /// Observable authentication state
  final isLoggedIn = false.obs;

  /// Get the current authentication state
  bool get isLoggedInValue => isLoggedIn.value;

  /// Log the user in
  void login() {
    isLoggedIn.value = true;
  }

  /// Log the user out
  void logout() {
    isLoggedIn.value = false;
  }
}
