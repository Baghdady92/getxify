import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

// Supplementary regression tests for
// https://github.com/jonataslaw/getx/issues/3350: a nested GetRouterOutlet
// navigator attached the HeroController installed by MaterialApp.router's
// HeroControllerScope — the same controller already attached to the root
// navigator — triggering Flutter's "A HeroController can not be shared by
// multiple Navigators" report and corrupting hero flights. Each outlet
// navigator now lives under its own persistent HeroControllerScope.

const shuttleKey = ValueKey('hero-flight-shuttle');

Widget shuttleBuilder(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  return const SizedBox(key: shuttleKey, width: 100, height: 100);
}

Widget heroBox(double size) {
  return Hero(
    tag: 'hero',
    flightShuttleBuilder: shuttleBuilder,
    child: SizedBox(width: size, height: size),
  );
}

GetMaterialApp buildApp() {
  return GetMaterialApp(
    initialRoute: '/home/list',
    getPages: [
      GetPage(
        name: '/home',
        participatesInRootNavigator: true,
        page: () => Scaffold(
          body: GetRouterOutlet(
            anchorRoute: '/home',
            initialRoute: '/home/list',
          ),
        ),
        children: [
          GetPage(
            name: '/list',
            page: () => Scaffold(body: heroBox(100)),
            children: [
              GetPage(
                name: '/detail',
                page: () => Scaffold(body: Center(child: heroBox(50))),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

void main() {
  tearDown(Get.reset);

  testWidgets('nested outlet navigator owns its own HeroControllerScope', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    final controllers = tester
        .widgetList<HeroControllerScope>(find.byType(HeroControllerScope))
        .map((scope) => scope.controller)
        .whereType<HeroController>()
        .toList();
    // One scope from MaterialApp.router (root navigator) and one from the
    // nested outlet; sharing a single controller between both navigators is
    // exactly the reported defect.
    expect(controllers.length, greaterThanOrEqualTo(2));
    expect(controllers.toSet().length, controllers.length);
  });

  testWidgets('push inside a nested outlet starts exactly one hero flight', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    Get.rootController.rootDelegate.toNamed('/home/list/detail');
    await tester.pump(const Duration(milliseconds: 40));
    await tester.pump(const Duration(milliseconds: 40));

    expect(tester.takeException(), isNull);
    expect(find.byKey(shuttleKey), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byKey(shuttleKey), findsNothing);
  });
}
