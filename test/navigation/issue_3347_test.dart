import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

// Regression tests for https://github.com/jonataslaw/getx/issues/3347
// (and its duplicate #2638): with doubly nested GetRouterOutlets, the outer
// outlet leaked the pages hosted by the deeper outlet into its own
// navigator, stacking them over the deeper outlet's host page so the inner
// router (and its surrounding chrome) disappeared.

Widget homeShell() {
  return Column(
    children: [
      const Text('home-shell'),
      Expanded(
        child: GetRouterOutlet(
          anchorRoute: '/home',
          initialRoute: '/home/settings',
        ),
      ),
    ],
  );
}

Widget settingsShell() {
  return Column(
    children: [
      const Text('settings-shell'),
      Expanded(
        child: GetRouterOutlet(
          anchorRoute: '/home/settings',
          initialRoute: '/home/settings/profile',
        ),
      ),
    ],
  );
}

GetMaterialApp buildApp() {
  return GetMaterialApp(
    initialRoute: '/home/settings',
    getPages: [
      GetPage(
        name: '/home',
        participatesInRootNavigator: true,
        page: () => Scaffold(body: homeShell()),
        children: [
          GetPage(
            name: '/settings',
            page: settingsShell,
            children: [
              GetPage(name: '/profile', page: () => const Text('profile-view')),
              GetPage(name: '/account', page: () => const Text('account-view')),
            ],
          ),
        ],
      ),
    ],
  );
}

void main() {
  tearDown(Get.reset);

  testWidgets('doubly nested outlets render without errors', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('home-shell'), findsOneWidget);
    expect(find.text('settings-shell'), findsOneWidget);
    expect(find.text('profile-view'), findsOneWidget);
  });

  testWidgets(
    'navigating inside the deeper outlet keeps the inner router visible',
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      Get.rootController.rootDelegate.toNamed('/home/settings/account');
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // The deep page must be hosted only by the inner outlet; before the
      // fix it was also pushed inside the outer outlet's navigator, covering
      // the settings shell (the inner router "disappeared").
      expect(find.text('home-shell'), findsOneWidget);
      expect(find.text('settings-shell'), findsOneWidget);
      expect(find.text('account-view'), findsOneWidget);
      expect(find.text('profile-view'), findsNothing);
    },
  );

  testWidgets('navigating back to the first inner child works', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    Get.rootController.rootDelegate.toNamed('/home/settings/account');
    await tester.pumpAndSettle();
    Get.rootController.rootDelegate.toNamed('/home/settings/profile');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('settings-shell'), findsOneWidget);
    expect(find.text('profile-view'), findsOneWidget);
    expect(find.text('account-view'), findsNothing);
  });
}
