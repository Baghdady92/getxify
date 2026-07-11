import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

void main() {
  testWidgets("close() on an already-dismissed snackbar is a no-op", (
    tester,
  ) async {
    late SnackbarController controller;

    await tester.pumpWidget(
      GetMaterialApp(
        home: ElevatedButton(
          child: const Text('Open Snackbar'),
          onPressed: () {
            controller = Get.rawSnackbar(
              title: 'title',
              message: "message",
              duration: const Duration(seconds: 1),
            );
          },
        ),
      ),
    );

    await tester.pump();
    await tester.tap(find.text('Open Snackbar'));
    expect(Get.isSnackbarOpen, true);

    // Let the duration timer expire and the snackbar fully dismiss.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(Get.isSnackbarOpen, false);

    // Closing again must not assert "Cannot remove entry from a
    // disposed snackbar".
    await controller.close();
    await controller.close(withAnimations: false);
    expect(tester.takeException(), isNull);
  });

  testWidgets("double close() does not assert", (tester) async {
    late SnackbarController controller;

    await tester.pumpWidget(
      GetMaterialApp(
        home: ElevatedButton(
          child: const Text('Open Snackbar'),
          onPressed: () {
            controller = Get.rawSnackbar(
              title: 'title',
              message: "message",
              duration: const Duration(seconds: 5),
            );
          },
        ),
      ),
    );

    await tester.pump();
    await tester.tap(find.text('Open Snackbar'));
    await tester.pumpAndSettle();
    expect(Get.isSnackbarOpen, true);

    final firstClose = controller.close();
    final secondClose = controller.close();
    await tester.pumpAndSettle();
    await firstClose;
    await secondClose;

    expect(Get.isSnackbarOpen, false);
    expect(tester.takeException(), isNull);
  });

  testWidgets("duration timer firing after close(withAnimations: false) "
      "does not assert", (tester) async {
    late SnackbarController controller;

    await tester.pumpWidget(
      GetMaterialApp(
        home: ElevatedButton(
          child: const Text('Open Snackbar'),
          onPressed: () {
            controller = Get.rawSnackbar(
              title: 'title',
              message: "message",
              duration: const Duration(seconds: 1),
            );
          },
        ),
      ),
    );

    await tester.pump();
    await tester.tap(find.text('Open Snackbar'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(Get.isSnackbarOpen, true);

    await controller.close(withAnimations: false);
    await tester.pump();
    expect(Get.isSnackbarOpen, false);

    // If the duration timer was not cancelled, it fires _removeEntry on the
    // disposed controller here.
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });
}
