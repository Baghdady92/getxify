import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

void main() {
  // https://github.com/jonataslaw/getx/issues/2995
  testWidgets(
      "widgets beside a width-constrained snackbar stay tappable while the bar stays interactive",
      (tester) async {
    const cornerButtonKey = Key('corner-button');
    var cornerButtonTaps = 0;
    var snackbarTaps = 0;

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              Positioned(
                top: 10,
                left: 10,
                width: 100,
                height: 40,
                child: ElevatedButton(
                  key: cornerButtonKey,
                  onPressed: () => cornerButtonTaps++,
                  child: const Text('Corner'),
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
        maxWidth: 200,
        snackPosition: SnackPosition.top,
        duration: const Duration(seconds: 5),
        onTap: (_) => snackbarTaps++,
      ),
    );
    await tester.pumpAndSettle();

    expect(Get.isSnackbarOpen, true);

    await tester.tap(find.byKey(cornerButtonKey), warnIfMissed: false);
    await tester.pump();

    expect(cornerButtonTaps, 1,
        reason:
            'a tap beside the width-constrained snackbar must reach the button');
    expect(Get.isSnackbarOpen, true);

    await tester.tap(find.text('bar1'));
    expect(snackbarTaps, 1,
        reason: 'the visible snackbar must still receive taps');

    await tester.drag(find.text('bar1'), const Offset(0.0, -50.0));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 500));

    expect(Get.isSnackbarOpen, false,
        reason: 'the visible snackbar must still be swipe-dismissible');

    await controller.close(withAnimations: false);
    await tester.pumpAndSettle();
  });
}
