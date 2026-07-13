import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

import 'utils/wrapper.dart';

void main() {
  testWidgets(
    "Routing.previous holds the popped route after Get.back (issue #3394)",
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

      Get.back();
      await tester.pumpAndSettle();

      expect(Get.currentRoute, '/first');
      expect(Get.previousRoute, '/second');
      expect(Get.previousRoute, isNot(equals(Get.currentRoute)));
    },
  );

  testWidgets(
    "previousRoute stays distinct from currentRoute across multiple pops",
    (tester) async {
      await tester.pumpWidget(
        WrapperNamed(
          initialRoute: '/first',
          namedRoutes: [
            GetPage(page: () => const Text('first'), name: '/first'),
            GetPage(page: () => const Text('second'), name: '/second'),
            GetPage(page: () => const Text('third'), name: '/third'),
          ],
        ),
      );
      await tester.pumpAndSettle();

      Get.toNamed('/second');
      await tester.pumpAndSettle();
      Get.toNamed('/third');
      await tester.pumpAndSettle();

      Get.back();
      await tester.pumpAndSettle();

      expect(Get.currentRoute, '/second');
      expect(Get.previousRoute, '/third');

      Get.back();
      await tester.pumpAndSettle();

      expect(Get.currentRoute, '/first');
      expect(Get.previousRoute, '/second');
    },
  );
}
