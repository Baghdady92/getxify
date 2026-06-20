import 'package:getxify/getxify.dart';

/// Controller for the settings screen
/// Manages app settings and preferences
class SettingsController extends GetxController {
  /// Observable counter for demo purposes
  final count = 0.obs;

  /// Observable for dark mode setting
  final isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  /// Increment the counter
  void increment() => count.value++;

  /// Toggle dark mode
  void toggleDarkMode([bool? value]) =>
      isDarkMode.value = value ?? !isDarkMode.value;
}
