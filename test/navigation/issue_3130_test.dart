import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

// https://github.com/jonataslaw/getx/issues/3130
//
// Transition.circularReveal hardcoded maxRadius: 800, so on screens whose
// half-diagonal exceeds 800 logical pixels (iPad Pro 12.9, large desktop
// windows) the reveal circle never covered the corners, leaving them
// permanently clipped (black). The clipper must fall back to its computed
// maximum radius so the circle always covers the full page.
void main() {
  tearDown(Get.reset);

  testWidgets(
    'CircularRevealTransition covers the corners of an iPad Pro 12.9 screen',
    (tester) async {
      late Widget transition;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            transition = CircularRevealTransition().buildTransitions(
              context,
              null,
              null,
              const AlwaysStoppedAnimation<double>(1),
              const AlwaysStoppedAnimation<double>(0),
              const SizedBox(),
            );
            return const SizedBox();
          },
        ),
      );

      final clipper =
          (transition as ClipPath).clipper! as CircularRevealClipper;

      // iPad Pro 12.9 logical resolution; its half-diagonal is ~854.
      const size = Size(1024, 1366);
      final path = clipper.getClip(size);

      expect(
        path.contains(Offset.zero),
        isTrue,
        reason: 'the fully revealed circle must cover the top-left corner',
      );
      expect(
        path.contains(const Offset(1023, 1365)),
        isTrue,
        reason: 'the fully revealed circle must cover the bottom-right corner',
      );
    },
  );

  testWidgets(
    'a settled circularReveal route is fully visible on a large screen',
    (tester) async {
      tester.view.physicalSize = const Size(1024, 1366);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      var cornerTapped = false;

      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/first',
          getPages: [
            GetPage(
              name: '/first',
              page: () => const Scaffold(body: Text('first')),
            ),
            GetPage(
              name: '/second',
              transition: Transition.circularReveal,
              page: () => Scaffold(
                body: Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () => cornerTapped = true,
                    child: const SizedBox(
                      width: 10,
                      height: 10,
                      child: ColoredBox(color: Colors.red),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      Get.toNamed('/second');
      await tester.pumpAndSettle();

      // With the reveal capped at 800 the corner stayed clipped even after
      // the transition settled, so the corner was not hit-testable.
      await tester.tapAt(const Offset(5, 5));
      expect(
        cornerTapped,
        isTrue,
        reason: 'the corner of the revealed page must be interactive',
      );
    },
  );
}
