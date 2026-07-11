import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

// Regression test for https://github.com/jonataslaw/getx/issues/2742:
// a GetRouterOutlet without anchorRoute keyed its nested navigator with the
// ROOT delegate's GlobalKey (Get.nestedKey(null) returns the root delegate),
// so the same GlobalKey was mounted by two navigators at once — an immediate
// duplicate-GlobalKey failure.

void main() {
  tearDown(Get.reset);

  testWidgets(
    'anchorless outlet does not reuse the root navigator GlobalKey',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/',
          getPages: [
            GetPage(
              name: '/',
              page: () => Scaffold(
                body: GetRouterOutlet(initialRoute: '/home'),
              ),
              children: [
                GetPage(name: '/home', page: () => const Text('home-view')),
              ],
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('home-view'), findsOneWidget);
      // Exactly one navigator carries the root delegate's GlobalKey.
      final rootKey = Get.rootController.rootDelegate.navigatorKey;
      final keyed = tester
          .widgetList<Navigator>(find.bySubtype<Navigator>())
          .where((navigator) => navigator.key == rootKey);
      expect(keyed.length, 1);
    },
  );
}
