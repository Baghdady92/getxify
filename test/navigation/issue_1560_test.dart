import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

// https://github.com/jonataslaw/getx/issues/1560
//
// Pushing a route with Transition.downToUp used to play the previous
// page's secondary (parallax) animation, sliding it away and revealing the
// navigator's black background behind both pages while the new page was
// still rising from the bottom. The outgoing page must stay in place, the
// same way it does for a fullscreen dialog.
GetMaterialApp buildApp() {
  return GetMaterialApp(
    initialRoute: '/first',
    getPages: [
      GetPage(
        name: '/first',
        // Cupertino plays a horizontal parallax on the outgoing page, which
        // is exactly what revealed the background in the report.
        transition: Transition.cupertino,
        page: () => const Scaffold(body: Text('first')),
      ),
      GetPage(
        name: '/second',
        transition: Transition.downToUp,
        transitionDuration: const Duration(milliseconds: 300),
        page: () => const Scaffold(body: Text('second')),
      ),
    ],
  );
}

void main() {
  tearDown(Get.reset);

  testWidgets(
    'the previous page stays in place while a downToUp route slides in',
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final firstTopLeft = tester.getTopLeft(find.text('first'));

      Get.toNamed('/second');
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      // Mid-transition the incoming page is still rising from the bottom...
      expect(tester.getTopLeft(find.text('second')).dy, greaterThan(0));
      // ...and the outgoing page must not have moved sideways, which would
      // reveal the navigator background behind both pages.
      expect(
        tester.getTopLeft(find.text('first')),
        firstTopLeft,
        reason:
            'the previous page must not play a parallax animation '
            'under a downToUp route',
      );

      await tester.pumpAndSettle();
      expect(find.text('second'), findsOneWidget);
    },
  );

  testWidgets('the previous page stays in place while a downToUp route pops', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final firstTopLeft = tester.getTopLeft(find.text('first'));

    Get.toNamed('/second');
    await tester.pumpAndSettle();

    Get.back();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(tester.getTopLeft(find.text('first')), firstTopLeft);

    await tester.pumpAndSettle();
    expect(find.text('first'), findsOneWidget);
    expect(find.text('second'), findsNothing);
  });
}
