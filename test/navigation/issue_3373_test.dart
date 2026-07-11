import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

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
        page: () => const Scaffold(body: Text('first')),
      ),
      GetPage(
        name: '/second',
        popGesture: true,
        gestureWidth: (context) => 80,
        page: () => const Scaffold(body: Text('second')),
      ),
    ],
  );
}

void main() {
  tearDown(Get.reset);

  testWidgets('drags beyond the configured gestureWidth do not pop', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    Get.toNamed('/second');
    await tester.pumpAndSettle();

    await tester.flingFrom(const Offset(400, 300), const Offset(350, 0), 1000);
    await tester.pumpAndSettle();

    expect(find.text('second'), findsOneWidget);
    expect(find.text('first'), findsNothing);
  });

  testWidgets('drags inside the configured gestureWidth pop the route', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    Get.toNamed('/second');
    await tester.pumpAndSettle();

    await tester.flingFrom(const Offset(40, 300), const Offset(700, 0), 1000);
    await tester.pumpAndSettle();

    expect(find.text('first'), findsOneWidget);
    expect(find.text('second'), findsNothing);
  });
}
