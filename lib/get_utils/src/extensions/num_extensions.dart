import 'dart:async';

import 'package:flutter/foundation.dart';

import '../get_utils/get_utils.dart';

extension GetNumUtils on num {
  bool isLowerThan(num b) => GetUtils.isLowerThan(this, b);

  bool isGreaterThan(num b) => GetUtils.isGreaterThan(this, b);

  bool isEqual(num b) => GetUtils.isEqual(this, b);

  /// Utility to delay some callback (or code execution).
  ///
  /// Sample:
  /// ```
  /// void main() async {
  ///   print('+ wait for 2 seconds');
  ///   await 2.delay();
  ///   print('- 2 seconds completed');
  ///   print('+ callback in 1.2sec');
  ///   1.delay(() => print('- 1.2sec callback called'));
  ///   print('currently running callback 1.2sec');
  /// }
  ///```
  Future delay([FutureOr Function()? callback]) async =>
      Future.delayed(Duration(milliseconds: (this * 1000).round()), callback);

  /// Utility to delay some callback (or code execution) with the ability to cancel.
  /// Returns a Timer that can be cancelled using [timer.cancel()].
  ///
  /// Sample:
  /// ```
  /// void main() {
  ///   print('+ start delay');
  ///   final timer = 5.delayCancellable(() => print('- callback called'));
  ///   print('- cancelling after 2 seconds');
  ///   2.delay().then((_) {
  ///     timer.cancel();
  ///     print('- timer cancelled');
  ///   });
  /// }
  /// ```
  Timer delayCancellable(VoidCallback callback) =>
      Timer(Duration(milliseconds: (this * 1000).round()), callback);
}
