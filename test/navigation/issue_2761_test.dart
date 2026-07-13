// Regression test for https://github.com/jonataslaw/getx/issues/2761
//
// Closing a snackbar that was still waiting in the queue (its animation
// controller not yet created) crashed with a null-check error, the modern
// form of the reported LateInitializationError on `_controller`.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

void main() {
  testWidgets('closing a queued, not-yet-shown snackbar does not throw', (
    tester,
  ) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));

    final first = Get.showSnackbar(
      const GetSnackBar(message: 'first', duration: Duration(seconds: 1)),
    );
    final second = Get.showSnackbar(
      const GetSnackBar(message: 'second', duration: Duration(seconds: 1)),
    );

    // 'second' is still queued behind 'first' and has no animation
    // controller yet; closing it must cancel it instead of crashing.
    await second.close();
    expect(tester.takeException(), isNull);

    await first.close(withAnimations: false);
    await tester.pumpAndSettle();

    expect(find.text('second'), findsNothing);
    expect(Get.isSnackbarOpen, false);
  });
}
