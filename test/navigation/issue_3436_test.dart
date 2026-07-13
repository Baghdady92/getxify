// Regression test for upstream issue #3436:
// Get.back(), the system back gesture and the iOS edge-swipe must pop
// imperatively pushed pageless routes (e.g. OpenContainer, raw
// Navigator.push) instead of removing pages from the delegate history,
// which tore down two screens at once.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

import 'utils/wrapper.dart';

void main() {
  testWidgets("Get.back pops only the pageless route pushed over a page", (
    tester,
  ) async {
    await tester.pumpWidget(
      Wrapper(
        initialRoute: '/home',
        namedRoutes: [
          GetPage(name: '/home', page: () => const Text('home')),
          GetPage(name: '/second', page: () => const Text('second')),
        ],
      ),
    );
    await tester.pumpAndSettle();

    Get.toNamed('/second');
    await tester.pumpAndSettle();
    expect(find.text('second'), findsOneWidget);

    Navigator.of(
      Get.context!,
    ).push(MaterialPageRoute(builder: (_) => const Text('pageless')));
    await tester.pumpAndSettle();
    expect(find.text('pageless'), findsOneWidget);

    Get.back();
    await tester.pumpAndSettle();

    // Only the pageless route must be gone; /second must survive.
    expect(find.text('pageless'), findsNothing);
    expect(find.text('second'), findsOneWidget);
    expect(Get.currentRoute, '/second');

    // A second back still pops pages declaratively.
    Get.back();
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
    expect(Get.currentRoute, '/home');
  });

  testWidgets("Get.back pops a pageless route over the only page", (
    tester,
  ) async {
    await tester.pumpWidget(
      Wrapper(
        initialRoute: '/home',
        namedRoutes: [
          GetPage(name: '/home', page: () => const Text('home')),
        ],
      ),
    );
    await tester.pumpAndSettle();

    Navigator.of(
      Get.context!,
    ).push(MaterialPageRoute(builder: (_) => const Text('pageless')));
    await tester.pumpAndSettle();
    expect(find.text('pageless'), findsOneWidget);

    Get.back();
    await tester.pumpAndSettle();

    expect(find.text('pageless'), findsNothing);
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets("system back pops only the pageless route pushed over a page", (
    tester,
  ) async {
    await tester.pumpWidget(
      Wrapper(
        initialRoute: '/home',
        namedRoutes: [
          GetPage(name: '/home', page: () => const Text('home')),
          GetPage(name: '/second', page: () => const Text('second')),
        ],
      ),
    );
    await tester.pumpAndSettle();

    Get.toNamed('/second');
    await tester.pumpAndSettle();

    Navigator.of(
      Get.context!,
    ).push(MaterialPageRoute(builder: (_) => const Text('pageless')));
    await tester.pumpAndSettle();
    expect(find.text('pageless'), findsOneWidget);

    // Simulates the Android system back button / predictive back gesture.
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      'flutter/navigation',
      const JSONMethodCodec().encodeMethodCall(const MethodCall('popRoute')),
      (_) {},
    );
    await tester.pumpAndSettle();

    expect(find.text('pageless'), findsNothing);
    expect(find.text('second'), findsOneWidget);
    expect(Get.currentRoute, '/second');
  });

  testWidgets("edge-swipe pops an imperatively pushed GetPageRoute", (
    tester,
  ) async {
    await tester.pumpWidget(
      Wrapper(
        initialRoute: '/home',
        namedRoutes: [
          GetPage(name: '/home', page: () => const Text('home')),
        ],
      ),
    );
    await tester.pumpAndSettle();

    Navigator.of(Get.context!).push(
      GetPageRoute(
        page: () => const Text('pageless'),
        popGesture: true,
        transition: Transition.rightToLeft,
        routeName: '/pageless',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('pageless'), findsOneWidget);

    // Drag from the left edge past the middle of the screen and release.
    final gesture = await tester.startGesture(const Offset(10, 300));
    await gesture.moveBy(const Offset(500, 0));
    await tester.pump(const Duration(milliseconds: 16));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('pageless'), findsNothing);
    expect(find.text('home'), findsOneWidget);
  });
}
