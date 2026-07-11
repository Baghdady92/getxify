import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

GetMaterialApp buildApp() {
  return GetMaterialApp(
    initialRoute: '/first',
    getPages: [
      GetPage(
        name: '/first',
        popGesture: true,
        page: () => const Scaffold(body: Text('first')),
      ),
      GetPage(
        name: '/second',
        popGesture: true,
        transition: Transition.leftToRight,
        page: () => const Scaffold(body: Text('second')),
      ),
    ],
  );
}

void main() {
  tearDown(Get.reset);

  testWidgets(
    'Transition.leftToRight page follows the finger during a '
    'right-to-left back drag',
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      Get.toNamed('/second');
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(const Offset(700, 300));
      await gesture.moveBy(const Offset(-200, 0));
      await tester.pump();

      expect(
        tester.getTopLeft(find.text('second')).dx,
        lessThan(0),
        reason: 'the page must slide towards the leading edge it came from',
      );

      await gesture.up();
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'Transition.leftToRight pops on a right-to-left fling',
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      Get.toNamed('/second');
      await tester.pumpAndSettle();

      await tester.flingFrom(
        const Offset(700, 300),
        const Offset(-600, 0),
        1000,
      );
      await tester.pumpAndSettle();

      expect(find.text('first'), findsOneWidget);
      expect(find.text('second'), findsNothing);
    },
  );

  testWidgets(
    'Transition.leftToRight ignores left-to-right drags for pop',
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      Get.toNamed('/second');
      await tester.pumpAndSettle();

      await tester.flingFrom(
        const Offset(100, 300),
        const Offset(600, 0),
        1000,
      );
      await tester.pumpAndSettle();

      expect(find.text('second'), findsOneWidget);
      expect(find.text('first'), findsNothing);
    },
  );
}
