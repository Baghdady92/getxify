import 'package:flutter/material.dart';
import 'package:getxify/getxify.dart';

import '../controllers/settings_controller.dart';

/// Settings screen view
/// Demonstrates state management with settings
class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'SettingsView is working',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Obx(() => Text('Counter: ${controller.count.value}')),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: controller.increment,
              child: const Text('Increment'),
            ),
            const SizedBox(height: 20),
            Obx(
              () => SwitchListTile(
                title: const Text('Dark Mode'),
                value: controller.isDarkMode.value,
                onChanged: controller.toggleDarkMode,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
