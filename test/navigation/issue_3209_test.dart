import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

// https://github.com/jonataslaw/getx/issues/3209
//
// The iOS back swipe was accepted anywhere on screen by default, hijacking
// horizontal gestures (sliders, carousels...). By default the drag must now
// only start near the edge the page entered from, like the native iOS
// back gesture. Routes that explicitly opt in with `popGesture: true` keep
// the historical full-screen swipe area.
GetMaterialApp buildApp({
  bool? routePopGesture,
  double Function(BuildContext)? gestureWidth,
}) {
  return GetMaterialApp(
    // Cupertino keeps the same transition subtree while a user gesture is
    // in progress; the default Android builders swap subtrees mid-gesture.
    defaultTransition: Transition.cupertino,
    popGesture: true,
    initialRoute: '/first',
    getPages: [
      GetPage(
        name: '/first',
        page: () => const Scaffold(body: Text('first')),
      ),
      GetPage(
        name: '/second',
        popGesture: routePopGesture,
        gestureWidth: gestureWidth,
        page: () => const Scaffold(body: Text('second')),
      ),
    ],
  );
}

void main() {
  tearDown(Get.reset);

  testWidgets('a drag starting mid-screen does not pop by default', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    Get.toNamed('/second');
    await tester.pumpAndSettle();

    await tester.flingFrom(const Offset(300, 300), const Offset(400, 0), 1000);
    await tester.pumpAndSettle();

    expect(find.text('second'), findsOneWidget);
    expect(find.text('first'), findsNothing);
  });

  testWidgets('a drag starting at the leading edge pops by default', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    Get.toNamed('/second');
    await tester.pumpAndSettle();

    await tester.flingFrom(const Offset(10, 300), const Offset(700, 0), 1000);
    await tester.pumpAndSettle();

    expect(find.text('first'), findsOneWidget);
    expect(find.text('second'), findsNothing);
  });

  testWidgets(
    'popGesture: true on the route keeps the full-screen swipe area',
    (tester) async {
      await tester.pumpWidget(buildApp(routePopGesture: true));
      await tester.pumpAndSettle();

      Get.toNamed('/second');
      await tester.pumpAndSettle();

      await tester.flingFrom(
        const Offset(300, 300),
        const Offset(400, 0),
        1000,
      );
      await tester.pumpAndSettle();

      expect(find.text('first'), findsOneWidget);
      expect(find.text('second'), findsNothing);
    },
  );

  testWidgets(
    'a gestureWidth of double.infinity restores full-screen detection',
    (tester) async {
      await tester.pumpWidget(
        buildApp(gestureWidth: (context) => double.infinity),
      );
      await tester.pumpAndSettle();

      Get.toNamed('/second');
      await tester.pumpAndSettle();

      await tester.flingFrom(
        const Offset(300, 300),
        const Offset(400, 0),
        1000,
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('first'), findsOneWidget);
      expect(find.text('second'), findsNothing);
    },
  );
}
