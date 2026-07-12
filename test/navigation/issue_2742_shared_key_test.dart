import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

// Regression tests for the residual part of
// https://github.com/jonataslaw/getx/issues/2742: every GetRouterOutlet
// anchored at the same route shares one nested-delegate GlobalKey, so two
// simultaneously mounted outlets for that anchor (duplicate shell pages
// stacked in the root navigator) crashed with "Multiple widgets used the
// same GlobalKey" as soon as both rebuilt in the same frame. The shared key
// is now attached to the most recently mounted outlet only.

Widget shell() {
  return Scaffold(
    body: Column(
      children: [
        const Text('shell'),
        Expanded(
          child: GetRouterOutlet(
            anchorRoute: '/home',
            initialRoute: '/home/tab1',
          ),
        ),
      ],
    ),
  );
}

GetMaterialApp buildApp() {
  return GetMaterialApp(
    initialRoute: '/home',
    getPages: [
      GetPage(
        name: '/home',
        participatesInRootNavigator: true,
        page: shell,
        children: [
          GetPage(name: '/tab1', page: () => const Text('tab1-view')),
          GetPage(name: '/tab2', page: () => const Text('tab2-view')),
        ],
      ),
    ],
  );
}

/// The navigators currently carrying the shared nested key for `/home`.
Iterable<Navigator> sharedKeyNavigators(WidgetTester tester) {
  final sharedKey = Get.nestedKey('/home')!.navigatorKey;
  return tester
      .widgetList<Navigator>(find.bySubtype<Navigator>(skipOffstage: false))
      .where((navigator) => navigator.key == sharedKey);
}

void main() {
  tearDown(Get.reset);

  testWidgets(
    'two simultaneously mounted outlets for the same anchor do not crash '
    'and share the key one at a time',
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(sharedKeyNavigators(tester).length, 1);

      // Stacks a second, rekeyed instance of the shell page in the root
      // navigator: both shells (and both same-anchor outlets) are mounted.
      Get.rootController.rootDelegate.toNamed(
        '/home',
        preventDuplicates: false,
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        tester.widgetList(find.text('shell', skipOffstage: false)).length,
        2,
      );
      expect(sharedKeyNavigators(tester).length, 1);

      // Rebuilds every outlet in the same frame through a delegate
      // notification; before the fix this crashed with "Multiple widgets
      // used the same GlobalKey".
      Get.rootController.rootDelegate.toNamed('/home/tab2');
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('tab2-view'), findsOneWidget);
      expect(sharedKeyNavigators(tester).length, 1);
    },
  );

  testWidgets(
    'the surviving outlet reclaims the shared key after the duplicate '
    'shell is popped',
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      Get.rootController.rootDelegate.toNamed(
        '/home',
        preventDuplicates: false,
      );
      await tester.pumpAndSettle();
      expect(
        tester.widgetList(find.text('shell', skipOffstage: false)).length,
        2,
      );

      Get.rootController.rootDelegate.back();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        tester.widgetList(find.text('shell', skipOffstage: false)).length,
        1,
      );
      // The remaining outlet re-adopted the shared key, so programmatic
      // access through the nested key reaches a live navigator again.
      expect(sharedKeyNavigators(tester).length, 1);
      expect(Get.nestedKey('/home')!.navigatorKey.currentState, isNotNull);
    },
  );
}
