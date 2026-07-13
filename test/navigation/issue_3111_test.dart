import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

// Regression test for https://github.com/jonataslaw/getx/issues/3111:
// a nested page marked with participatesInRootNavigator: true was rendered
// by the root navigator AND picked by the GetRouterOutlet anchored on its
// parent, mounting the page (and its controllers) twice.

GetMaterialApp buildApp() {
  return GetMaterialApp(
    initialRoute: '/',
    getPages: [
      GetPage(
        name: '/',
        participatesInRootNavigator: true,
        page: () => Scaffold(
          body: Column(
            children: [
              const Text('root-shell'),
              Expanded(
                child: GetRouterOutlet(anchorRoute: '/', initialRoute: '/home'),
              ),
            ],
          ),
        ),
        children: [
          GetPage(name: '/home', page: () => const Text('home-view')),
          GetPage(
            name: '/settings',
            participatesInRootNavigator: true,
            page: () => const Text('settings-view'),
          ),
        ],
      ),
    ],
  );
}

void main() {
  tearDown(Get.reset);

  testWidgets('outlet shows initialRoute child on start', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('root-shell'), findsOneWidget);
    expect(find.text('home-view'), findsOneWidget);
  });

  testWidgets(
    'page participating in the root navigator is mounted exactly once',
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      Get.rootController.rootDelegate.toNamed('/settings');
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('settings-view'), findsOneWidget);
      // Before the fix the outlet anchored at '/' also picked the settings
      // page, mounting a second (offstage) copy inside the root shell.
      expect(find.text('settings-view', skipOffstage: false), findsOneWidget);
    },
  );
}
