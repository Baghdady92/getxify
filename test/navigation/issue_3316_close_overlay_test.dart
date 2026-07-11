// Regression test for upstream issue #3316:
// Get.closeOverlay() called right after an awaited navigation returns must
// close the bottom sheet instead of popping page routes like Get.back().
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

import 'utils/wrapper.dart';

void main() {
  testWidgets(
    "Get.closeOverlay after awaited Get.toNamed closes the sheet, not pages",
    (tester) async {
      await tester.pumpWidget(
        Wrapper(
          initialRoute: '/home',
          namedRoutes: [
            GetPage(name: '/home', page: () => const Text('home')),
            GetPage(name: '/second', page: () => const Text('second')),
            GetPage(name: '/third', page: () => const Text('third')),
          ],
        ),
      );
      await tester.pumpAndSettle();

      Get.toNamed('/second');
      await tester.pumpAndSettle();
      expect(find.text('second'), findsOneWidget);

      showModalBottomSheet(
        context: Get.context!,
        builder: (_) => const Text('sheet'),
      );
      await tester.pumpAndSettle();
      expect(find.text('sheet'), findsOneWidget);

      // Mirrors the reporter's flow: navigate from the sheet, and close the
      // sheet as soon as the awaited navigation future completes.
      var closeOverlayCalled = false;
      unawaited(() async {
        await Get.toNamed('/third');
        Get.closeOverlay();
        closeOverlayCalled = true;
      }());
      await tester.pumpAndSettle();
      expect(find.text('third'), findsOneWidget);

      Get.back();
      await tester.pumpAndSettle();

      expect(closeOverlayCalled, true);
      // The sheet must be closed...
      expect(find.text('sheet'), findsNothing);
      // ...and /second must NOT have been popped.
      expect(find.text('second'), findsOneWidget);
      expect(Get.currentRoute, '/second');
    },
  );

  testWidgets("Get.closeOverlay does not pop page routes", (tester) async {
    await tester.pumpWidget(
      Wrapper(
        initialRoute: '/home',
        namedRoutes: [
          GetPage(name: '/home', page: () => const Text('home')),
          GetPage(name: '/second', page: () => const Text('second')),
        ],
      ),
    );
    await tester.pumpAndSettle();

    Get.toNamed('/second');
    await tester.pumpAndSettle();
    expect(find.text('second'), findsOneWidget);

    Get.closeOverlay();
    await tester.pumpAndSettle();

    expect(find.text('second'), findsOneWidget);
    expect(Get.currentRoute, '/second');
  });
}
