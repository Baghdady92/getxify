// Regression test for https://github.com/jonataslaw/getx/issues/2400
//
// SnackbarController.closeCurrentSnackbar and cancelAllSnackbars now accept
// a withAnimations flag, forwarded to SnackbarController.close, so the
// current snackbar can be dismissed without playing its exit animation.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

void main() {
  testWidgets(
    'closeCurrentSnackbar(withAnimations: false) closes immediately',
    (tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));

      Get.rawSnackbar(message: 'hello', duration: const Duration(seconds: 5));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('hello'), findsOneWidget);

      await SnackbarController.closeCurrentSnackbar(withAnimations: false);
      await tester.pump();

      expect(find.text('hello'), findsNothing);
      expect(Get.isSnackbarOpen, false);
    },
  );

  testWidgets('closeCurrentSnackbar() still animates by default', (
    tester,
  ) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));

    Get.rawSnackbar(message: 'hello', duration: const Duration(seconds: 5));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('hello'), findsOneWidget);

    SnackbarController.closeCurrentSnackbar();
    await tester.pump();

    // Mid exit animation the snackbar is still on screen.
    expect(find.text('hello'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('hello'), findsNothing);
    expect(Get.isSnackbarOpen, false);
  });

  testWidgets('cancelAllSnackbars(withAnimations: false) closes immediately', (
    tester,
  ) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));

    Get.rawSnackbar(message: 'hello', duration: const Duration(seconds: 5));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('hello'), findsOneWidget);

    await SnackbarController.cancelAllSnackbars(withAnimations: false);
    await tester.pump();

    expect(find.text('hello'), findsNothing);
    expect(Get.isSnackbarOpen, false);
  });
}
