// Regression test for https://github.com/jonataslaw/getx/issues/2257
//
// A snackbar closed while still waiting in the queue must never mount its
// overlay when the queue reaches it, and the queue must keep working.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

void main() {
  testWidgets('snackbar closed before being shown never mounts', (
    tester,
  ) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));

    Get.rawSnackbar(
      message: 'first',
      duration: const Duration(milliseconds: 500),
    );
    final second = Get.showSnackbar(
      const GetSnackBar(
        message: 'second',
        duration: Duration(milliseconds: 500),
      ),
    );

    // Cancel 'second' while it is still waiting behind 'first'.
    await second.close(withAnimations: false);

    await tester.pump();
    expect(find.text('first'), findsOneWidget);

    // Let 'first' expire; the queue then reaches the cancelled 'second' job,
    // which must not be displayed nor crash.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('second'), findsNothing);
    expect(Get.isSnackbarOpen, false);
    expect(tester.takeException(), isNull);

    // The queue keeps working for subsequent snackbars.
    Get.rawSnackbar(
      message: 'third',
      duration: const Duration(milliseconds: 500),
    );
    await tester.pump();
    expect(find.text('third'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(Get.isSnackbarOpen, false);
  });
}
