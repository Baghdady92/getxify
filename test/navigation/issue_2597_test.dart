import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

import 'utils/wrapper.dart';

void main() {
  testWidgets(
    "Get.currentRoute keeps the page name after dismissing a dialog "
    "stacked over a bottomsheet (issue #2597)",
    (tester) async {
      await tester.pumpWidget(
        WrapperNamed(
          initialRoute: '/home',
          namedRoutes: [
            GetPage(page: () => const Text('home'), name: '/home'),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(Get.currentRoute, '/home');

      Get.bottomSheet(const Text('sheet'));
      await tester.pumpAndSettle();

      Get.dialog(const Text('dialog'));
      await tester.pumpAndSettle();

      expect(Get.isDialogOpen, true);
      expect(Get.isBottomSheetOpen, true);
      expect(Get.currentRoute, '/home');

      Get.backLegacy();
      await tester.pumpAndSettle();

      expect(Get.isDialogOpen, false);
      expect(Get.currentRoute, '/home');
      expect(Get.currentRoute, isNot(startsWith('BOTTOMSHEET')));

      Get.backLegacy();
      await tester.pumpAndSettle();

      expect(Get.isBottomSheetOpen, false);
      expect(Get.currentRoute, '/home');
    },
  );

  testWidgets(
    "Get.currentRoute keeps the page name after dismissing stacked dialogs "
    "(issue #2597)",
    (tester) async {
      await tester.pumpWidget(
        WrapperNamed(
          initialRoute: '/home',
          namedRoutes: [
            GetPage(page: () => const Text('home'), name: '/home'),
          ],
        ),
      );
      await tester.pumpAndSettle();

      Get.dialog(const Text('first dialog'));
      await tester.pumpAndSettle();

      Get.dialog(const Text('second dialog'));
      await tester.pumpAndSettle();

      expect(Get.currentRoute, '/home');

      Get.backLegacy();
      await tester.pumpAndSettle();

      expect(Get.currentRoute, '/home');
      expect(Get.currentRoute, isNot(startsWith('DIALOG')));

      Get.backLegacy();
      await tester.pumpAndSettle();

      expect(Get.isDialogOpen, false);
      expect(Get.currentRoute, '/home');
    },
  );
}
