import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

const markerKey = ValueKey('custom-page-transitions-builder');

/// A [PageTransitionsBuilder] that tags the transition subtree with
/// [markerKey], so tests can detect whether the app theme's
/// [PageTransitionsTheme] was actually consulted.
class MarkerPageTransitionsBuilder extends PageTransitionsBuilder {
  const MarkerPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return KeyedSubtree(key: markerKey, child: child);
  }
}

GetMaterialApp buildApp() {
  return GetMaterialApp(
    theme: ThemeData(
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          for (final platform in TargetPlatform.values)
            platform: const MarkerPageTransitionsBuilder(),
        },
      ),
    ),
    initialRoute: '/first',
    getPages: [
      GetPage(name: '/first', page: () => const Scaffold(body: Text('first'))),
      GetPage(
        name: '/second',
        page: () => const Scaffold(body: Text('second')),
      ),
    ],
  );
}

void main() {
  tearDown(Get.reset);

  testWidgets(
    'Get.defaultTransition stays null when the app does not set one',
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(Get.defaultTransition, isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets(
    'routes without an explicit transition honor the theme '
    'pageTransitionsTheme on iOS',
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      Get.toNamed('/second');
      await tester.pumpAndSettle();

      expect(find.text('second'), findsOneWidget);
      expect(find.byKey(markerKey), findsWidgets);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );
}
