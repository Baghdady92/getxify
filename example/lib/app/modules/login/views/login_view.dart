import 'package:flutter/material.dart';
import 'package:getxify/getxify.dart';

import '../../../../services/auth_service.dart';
import '../../../routes/app_pages.dart';
import '../controllers/login_controller.dart';

/// Login screen view
/// Demonstrates authentication flow with route guards
class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              final isLoggedIn = AuthService.to.isLoggedInValue;
              return Text(
                'You are currently:'
                ' ${isLoggedIn ? "Logged In" : "Not Logged In"}'
                "\nIt's impossible to enter this "
                "route when you are logged in!",
              );
            }),
            const SizedBox(height: 20),
            Obx(
              () => controller.isLoading.value
                  ? const CircularProgressIndicator()
                  : MaterialButton(
                      child: const Text(
                        'Do LOGIN !!',
                        style: TextStyle(color: Colors.blue, fontSize: 20),
                      ),
                      onPressed: () async {
                        final thenTo = context.params['then'];
                        await controller.login();
                        AuthService.to.login();
                        Get.offNamed(thenTo ?? Routes.home);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
