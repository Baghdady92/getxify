// Regression test for upstream issue #3224: on Flutter Web, creating a
// root GetDelegate applies the path URL strategy; doing so more than once
// per process (remounting GetRoot, hot restart) crashed with the engine
// assertion "Cannot set URL strategy a second time or after the app has
// been initialized". Run with: flutter test --platform chrome
@TestOn('browser')
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

void main() {
  test('creating several root GetDelegates sets the URL strategy once', () {
    GetDelegate(
      pages: [GetPage(name: '/', page: () => const SizedBox.shrink())],
    );

    // A second root delegate in the same process must not attempt to set
    // the URL strategy again.
    GetDelegate(
      pages: [GetPage(name: '/', page: () => const SizedBox.shrink())],
    );
  });
}
