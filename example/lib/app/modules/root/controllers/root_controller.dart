import 'package:getxify/getxify.dart';

/// Controller for the root navigator
/// Manages the top-level navigation state
class RootController extends GetxController {
  /// Observable counter for demo purposes
  final count = 0.obs;

  /// Increment the counter
  void increment() => count.value++;
}
