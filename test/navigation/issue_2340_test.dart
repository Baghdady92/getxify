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

ThemeData themeWithMarkerTransitions() {
  return ThemeData(
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        for (final platform in TargetPlatform.values)
          platform: const MarkerPageTransitionsBuilder(),
      },
    ),
  );
}

void main() {
  tearDown(Get.reset);

  testWidgets(
    'Transition.native uses the pageTransitionsTheme of the app theme',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          theme: themeWithMarkerTransitions(),
          initialRoute: '/first',
          getPages: [
            GetPage(
              name: '/first',
              page: () => const Scaffold(body: Text('first')),
              transition: Transition.fadeIn,
            ),
            GetPage(
              name: '/second',
              page: () => const Scaffold(body: Text('second')),
              transition: Transition.native,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(markerKey), findsNothing);

      Get.toNamed('/second');
      await tester.pumpAndSettle();

      expect(find.text('second'), findsOneWidget);
      expect(find.byKey(markerKey), findsOneWidget);
    },
  );
}
