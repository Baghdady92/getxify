import 'package:flutter/foundation.dart';

import 'log.dart';
import 'smart_management.dart';

/// GetInterface allows any auxiliary package to be merged into the "Get"
/// class through extensions
abstract class GetInterface {
  SmartManagement smartManagement = SmartManagement.full;
  bool isLogEnable = kDebugMode;
  LogWriterCallback log = defaultLogWriterCallback;

  /// Print information to the console
  void printInfo({String? info, String? title}) {
    log('$title $info', isError: false);
  }
}
