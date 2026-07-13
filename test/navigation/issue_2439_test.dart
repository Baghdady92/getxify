// Regression tests for upstream issue #2439:
// A controller registered with Get.put inside a native (non-GetX) overlay
// builder — showModalBottomSheet, showDialog — must be released when the
// overlay is dismissed. Native routes never report their disposal to the
// RouterReportManager, so without observer-side cleanup the controller
// leaks forever.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

class SheetController extends GetxController {}

class DialogController extends GetxController {}

void main() {
  tearDown(Get.reset);

  testWidgets(
    'controller put inside a showModalBottomSheet builder is released on '
    'dismiss',
    (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: Text('home'))),
      );
      await tester.pumpAndSettle();

      showModalBottomSheet<void>(
        context: Get.context!,
        builder: (_) {
          Get.put(SheetController());
          return const Text('sheet');
        },
      );
      await tester.pumpAndSettle();
      expect(find.text('sheet'), findsOneWidget);
      expect(Get.isRegistered<SheetController>(), isTrue);

      Navigator.of(Get.context!).pop();
      await tester.pumpAndSettle();

      expect(find.text('sheet'), findsNothing);
      expect(Get.isRegistered<SheetController>(), isFalse);
    },
  );

  testWidgets(
    'controller put inside a native showDialog builder is released on '
    'dismiss',
    (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: Text('home'))),
      );
      await tester.pumpAndSettle();

      showDialog<void>(
        context: Get.context!,
        builder: (_) {
          Get.put(DialogController());
          return const Text('dialog');
        },
      );
      await tester.pumpAndSettle();
      expect(Get.isRegistered<DialogController>(), isTrue);

      Navigator.of(Get.context!).pop();
      await tester.pumpAndSettle();

      expect(Get.isRegistered<DialogController>(), isFalse);
    },
  );

  testWidgets(
    'a controller of the page below survives a native sheet dismissal',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                Get.put(SheetController());
                return const Text('home');
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(Get.isRegistered<SheetController>(), isTrue);

      showModalBottomSheet<void>(
        context: Get.context!,
        builder: (_) => const Text('sheet'),
      );
      await tester.pumpAndSettle();

      Navigator.of(Get.context!).pop();
      await tester.pumpAndSettle();

      expect(Get.isRegistered<SheetController>(), isTrue);
    },
  );
}
