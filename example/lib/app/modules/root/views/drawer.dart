import 'package:flutter/material.dart';
import 'package:getxify/getxify.dart';

import '../../../routes/app_pages.dart';
import '../controllers/root_controller.dart';

class DrawerWidget extends GetView<RootController> {
  const DrawerWidget({super.key});

  static const Color _headerColor = Colors.red;
  static const Color _loginColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(height: 100, color: _headerColor),
          ListTile(
            title: const Text('Home'),
            onTap: () {
              Get.toNamed(Routes.home);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: const Text('Settings'),
            onTap: () {
              Get.toNamed(Routes.settings);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: const Text('Login', style: TextStyle(color: _loginColor)),
            onTap: () {
              Get.toNamed(Routes.login);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
