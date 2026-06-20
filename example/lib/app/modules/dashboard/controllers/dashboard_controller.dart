import 'dart:async';

import 'package:getxify/getxify.dart';

/// Controller for the dashboard screen
/// Demonstrates reactive state with a live clock
class DashboardController extends GetxController {
  /// Observable current time
  final now = DateTime.now().obs;
  Timer? _timer;

  @override
  void onReady() {
    super.onReady();
    // Update time every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      now.value = DateTime.now();
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
