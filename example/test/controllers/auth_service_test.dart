import 'package:example/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('initially not logged in', () {
      expect(authService.isLoggedInValue, false);
    });

    test('login sets isLoggedIn to true', () {
      authService.login();
      expect(authService.isLoggedInValue, true);
    });

    test('logout sets isLoggedIn to false', () {
      authService.login();
      authService.logout();
      expect(authService.isLoggedInValue, false);
    });
  });
}
