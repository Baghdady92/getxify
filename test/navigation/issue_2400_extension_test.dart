// Regression test for https://github.com/jonataslaw/getx/issues/2400
// (Get extension wrappers)
//
// Get.closeCurrentSnackbar and Get.closeAllSnackbars forward the
// [withAnimations] flag to the SnackbarController statics, so the current
// snackbar can be dismissed without playing its exit animation from the
// Get facade as well. This file fails to compile without the fix
// (no such named parameter), proving the additive API.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

void main() {
  testWidgets(
      'Get.closeCurrentSnackbar(withAnimations: false) closes immediately',
      (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));

    Get.rawSnackbar(message: 'hello', duration: const Duration(seconds: 5));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('hello'), findsOneWidget);

    await Get.closeCurrentSnackbar(withAnimations: false);
    await tester.pump();

    expect(find.text('hello'), findsNothing);
    expect(Get.isSnackbarOpen, false);
  });

  testWidgets('Get.closeCurrentSnackbar() still animates by default',
      (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));

    Get.rawSnackbar(message: 'hello', duration: const Duration(seconds: 5));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('hello'), findsOneWidget);

    Get.closeCurrentSnackbar();
    await tester.pump();

    // Mid exit animation the snackbar is still on screen.
    expect(find.text('hello'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('hello'), findsNothing);
    expect(Get.isSnackbarOpen, false);
  });

  testWidgets(
      'Get.closeAllSnackbars(withAnimations: false) closes immediately',
      (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));

    Get.rawSnackbar(message: 'hello', duration: const Duration(seconds: 5));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('hello'), findsOneWidget);

    Get.closeAllSnackbars(withAnimations: false);
    await tester.pump();

    expect(find.text('hello'), findsNothing);
    expect(Get.isSnackbarOpen, false);
  });
}
