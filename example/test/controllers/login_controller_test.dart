import 'package:example/app/modules/login/controllers/login_controller.dart';
import 'package:example/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

void main() {
  group('LoginController', () {
    late LoginController controller;
    late AuthService authService;

    setUp(() {
      authService = AuthService();
      Get.put(authService);
      controller = LoginController();
    });

    tearDown(() {
      controller.dispose();
      Get.reset();
    });

    test('initially not loading', () {
      expect(controller.isLoading.value, false);
    });

    test('has authService accessor', () {
      expect(controller.authService, isNotNull);
    });

    test('login sets loading state', () async {
      final future = controller.login();
      expect(controller.isLoading.value, true);
      await future;
      expect(controller.isLoading.value, false);
    });

    test('login updates auth state', () async {
      expect(authService.isLoggedInValue, false);
      await controller.login();
      expect(authService.isLoggedInValue, true);
    });
  });
}
