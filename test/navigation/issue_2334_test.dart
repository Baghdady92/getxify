import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

import 'utils/wrapper.dart';

void main() {
  testWidgets(
    "Get.previousRoute survives opening and closing a bottomsheet (issue #2334)",
    (tester) async {
      await tester.pumpWidget(
        WrapperNamed(
          initialRoute: '/first',
          namedRoutes: [
            GetPage(page: () => const Text('first'), name: '/first'),
            GetPage(page: () => const Text('second'), name: '/second'),
          ],
        ),
      );
      await tester.pumpAndSettle();

      Get.toNamed('/second');
      await tester.pumpAndSettle();

      expect(Get.currentRoute, '/second');
      expect(Get.previousRoute, '/first');

      Get.bottomSheet(const Text('sheet'));
      await tester.pumpAndSettle();

      expect(Get.isBottomSheetOpen, true);
      expect(Get.currentRoute, '/second');
      expect(Get.previousRoute, '/first');

      Get.backLegacy();
      await tester.pumpAndSettle();

      expect(Get.isBottomSheetOpen, false);
      expect(Get.currentRoute, '/second');
      expect(Get.previousRoute, '/first');
    },
  );

  testWidgets(
    "Get.previousRoute survives opening and closing a dialog (issue #2334)",
    (tester) async {
      await tester.pumpWidget(
        WrapperNamed(
          initialRoute: '/first',
          namedRoutes: [
            GetPage(page: () => const Text('first'), name: '/first'),
            GetPage(page: () => const Text('second'), name: '/second'),
          ],
        ),
      );
      await tester.pumpAndSettle();

      Get.toNamed('/second');
      await tester.pumpAndSettle();

      Get.dialog(const Text('dialog'));
      await tester.pumpAndSettle();

      expect(Get.isDialogOpen, true);
      expect(Get.currentRoute, '/second');
      expect(Get.previousRoute, '/first');

      Get.backLegacy();
      await tester.pumpAndSettle();

      expect(Get.isDialogOpen, false);
      expect(Get.currentRoute, '/second');
      expect(Get.previousRoute, '/first');
    },
  );
}
