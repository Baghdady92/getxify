import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

void main() {
  // https://github.com/jonataslaw/getx/issues/3012
  testWidgets(
    "taps in the snackbar margin reach widgets underneath while the bar stays interactive",
    (tester) async {
      const underButtonKey = Key('under-button');
      var underButtonTaps = 0;
      var snackbarTaps = 0;

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton(
                      key: underButtonKey,
                      onPressed: () => underButtonTaps++,
                      child: const Text('Under'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();

      final controller = Get.showSnackbar(
        GetSnackBar(
          message: 'bar1',
          margin: const EdgeInsets.only(left: 8, right: 8, bottom: 300),
          snackPosition: SnackPosition.bottom,
          duration: const Duration(seconds: 5),
          onTap: (_) => snackbarTaps++,
        ),
      );
      await tester.pumpAndSettle();

      expect(Get.isSnackbarOpen, true);

      await tester.tap(find.byKey(underButtonKey), warnIfMissed: false);
      await tester.pump();

      expect(
        underButtonTaps,
        1,
        reason: 'a tap inside the snackbar margin must reach the button',
      );
      expect(Get.isSnackbarOpen, true);

      await tester.tap(find.text('bar1'));
      expect(
        snackbarTaps,
        1,
        reason: 'the visible snackbar must still receive taps',
      );

      await tester.drag(find.text('bar1'), const Offset(0.0, 300.0));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        Get.isSnackbarOpen,
        false,
        reason: 'the visible snackbar must still be swipe-dismissible',
      );

      await controller.close(withAnimations: false);
      await tester.pumpAndSettle();
    },
  );
}
