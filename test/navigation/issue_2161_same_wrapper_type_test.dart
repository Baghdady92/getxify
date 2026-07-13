// Regression test for upstream issue #2161: two different page closures
// returning the same widget type produce the same auto-generated route
// name, and the second Get.to used to rebuild the first page ("nothing
// happens") because the route tree lookup resolved to the stale first
// registration.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

import 'utils/wrapper.dart';

class FirstBody extends StatelessWidget {
  const FirstBody({super.key});

  @override
  Widget build(BuildContext context) => const Text('first body');
}

class SecondBody extends StatelessWidget {
  const SecondBody({super.key});

  @override
  Widget build(BuildContext context) => const Text('second body');
}

void main() {
  testWidgets(
    'Get.to navigates when two closures share the same wrapper widget type',
    (tester) async {
      await tester.pumpWidget(const Wrapper(child: Text('home')));
      await tester.pumpAndSettle();

      // Both closures have the static type `Directionality Function()`, so
      // they collide on the same auto-generated route name.
      Get.to(
        () => const Directionality(
          textDirection: TextDirection.ltr,
          child: FirstBody(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('first body'), findsOneWidget);

      Get.to(
        () => const Directionality(
          textDirection: TextDirection.ltr,
          child: SecondBody(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('second body'), findsOneWidget);
      expect(find.text('first body'), findsNothing);
    },
  );

  testWidgets(
    'a superseded Get.to future resolves and cleans its route tree entry',
    (tester) async {
      await tester.pumpWidget(const Wrapper(child: Text('home')));
      await tester.pumpAndSettle();

      final delegate = Get.rootController.rootDelegate;
      final baseline = delegate.registeredRoutes.length;

      var firstResolved = false;
      Get.to(
        () => const Directionality(
          textDirection: TextDirection.ltr,
          child: FirstBody(),
        ),
      )?.then((_) => firstResolved = true);
      await tester.pumpAndSettle();

      Get.to(
        () => const Directionality(
          textDirection: TextDirection.ltr,
          child: SecondBody(),
        ),
      );
      await tester.pumpAndSettle();

      // The first navigation was superseded by the reorder: its future must
      // resolve so its temporary route registration is removed, leaving
      // only the in-flight second one.
      expect(firstResolved, isTrue);
      expect(delegate.registeredRoutes.length, baseline + 1);
    },
  );
}
