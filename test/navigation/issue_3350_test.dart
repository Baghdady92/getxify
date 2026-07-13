import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

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

GetMaterialApp buildApp() {
  return GetMaterialApp(
    // Cupertino keeps the same transition subtree while a user gesture is
    // in progress; the default Android builders swap subtrees mid-gesture,
    // which would end the drag under test for unrelated reasons.
    defaultTransition: Transition.cupertino,
    initialRoute: '/first',
    getPages: [
      GetPage(
        name: '/first',
        popGesture: true,
        page: () => Scaffold(
          body: Hero(
            tag: 'hero',
            transitionOnUserGestures: true,
            flightShuttleBuilder: shuttleBuilder,
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      ),
      GetPage(
        name: '/second',
        popGesture: true,
        page: () => Scaffold(
          body: Center(
            child: Hero(
              tag: 'hero',
              transitionOnUserGestures: true,
              flightShuttleBuilder: shuttleBuilder,
              child: const SizedBox(width: 50, height: 50),
            ),
          ),
        ),
      ),
    ],
  );
}

void main() {
  tearDown(Get.reset);

  test('GetNavigator does not register its own HeroController', () {
    final navigator = GetNavigator(
      pages: const [MaterialPage(child: SizedBox())],
    );
    expect(navigator.observers.whereType<HeroController>(), isEmpty);
  });

  testWidgets('push starts exactly one hero flight', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    Get.toNamed('/second');
    await tester.pump(const Duration(milliseconds: 40));
    await tester.pump(const Duration(milliseconds: 40));

    expect(find.byKey(shuttleKey), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byKey(shuttleKey), findsNothing);
  });

  testWidgets(
    'gesture back starts exactly one hero flight with transitionOnUserGestures',
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      Get.toNamed('/second');
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(const Offset(10, 300));
      await gesture.moveBy(const Offset(500, 0));
      await tester.pump();

      expect(find.byKey(shuttleKey), findsOneWidget);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.byKey(shuttleKey), findsNothing);
    },
  );

  testWidgets('back gesture reports a user gesture to the navigator', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    Get.toNamed('/second');
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(GetNavigator));
    expect(navigator.userGestureInProgress, isFalse);

    final gesture = await tester.startGesture(const Offset(10, 300));
    await gesture.moveBy(const Offset(100, 0));
    await tester.pump();

    expect(navigator.userGestureInProgress, isTrue);

    await gesture.up();
    await tester.pumpAndSettle();

    expect(navigator.userGestureInProgress, isFalse);
  });
}
