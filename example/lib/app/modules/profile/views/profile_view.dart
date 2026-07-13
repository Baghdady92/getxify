import 'package:flutter/material.dart';
import 'package:getxify/getxify.dart';

import '../../../routes/app_pages.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  static const Color _backgroundColor = Colors.amber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => controller.logout(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'ProfileView is working',
              style: TextStyle(fontSize: 20),
            ),
            const Hero(tag: 'heroLogo', child: FlutterLogo()),
            const SizedBox(height: 20),
            Obx(() => Text('Name: ${controller.userName.value}')),
            Obx(() => Text('Email: ${controller.userEmail.value}')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.defaultDialog(
                  title: 'Test Dialog !!',
                  barrierDismissible: true,
                );
              },
              child: const Text('Show a test dialog'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.defaultDialog(
                  title: 'Test Dialog In Home Outlet !!',
                  barrierDismissible: true,
                  id: Routes.home,
                );
              },
              child: const Text('Show a test dialog in Home router outlet'),
            ),
          ],
        ),
      ),
    );
  }
}
