import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

// https://github.com/jonataslaw/getx/issues/3109
//
// Transition.predictiveBack opts a single route into Flutter's
// PredictiveBackPageTransitionsBuilder without configuring the theme's
// pageTransitionsTheme, mirroring how Transition.native delegates to the
// theme builders.
GetMaterialApp buildApp() {
  return GetMaterialApp(
    initialRoute: '/first',
    getPages: [
      GetPage(
        name: '/first',
        page: () => const Scaffold(body: Text('first')),
      ),
      GetPage(
        name: '/second',
        transition: Transition.predictiveBack,
        page: () => const Scaffold(body: Text('second')),
      ),
    ],
  );
}

void main() {
  tearDown(Get.reset);

  testWidgets('Transition.predictiveBack pushes and pops the route', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    Get.toNamed('/second');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);

    await tester.pumpAndSettle();
    expect(find.text('second'), findsOneWidget);
    expect(find.text('first'), findsNothing);

    Get.back();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('first'), findsOneWidget);
    expect(find.text('second'), findsNothing);
  });

  testWidgets(
    'Transition.predictiveBack does not disturb sibling transitions',
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      Get.toNamed('/second');
      await tester.pumpAndSettle();

      Get.offNamed('/first');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('first'), findsOneWidget);
    },
  );
}
