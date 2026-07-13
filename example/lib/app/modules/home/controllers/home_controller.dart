import 'package:getxify/getxify.dart';

/// Controller for the home screen
/// Manages the bottom navigation and nested routing
class HomeController extends GetxController {
  /// Current selected tab index
  final currentIndex = 0.obs;

  /// Change the current tab
  void changeTab(int index) {
    currentIndex.value = index;
  }
}
