import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

// https://github.com/jonataslaw/getx/issues/2503
// The transitionDuration given to GetMaterialApp/GetCupertinoApp was
// stored but never read, so pushes always animated with the 300ms
// default regardless of the configured value.
void main() {
  testWidgets('app-level transitionDuration drives route transitions', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        transitionDuration: const Duration(milliseconds: 500),
        defaultTransition: Transition.cupertino,
        initialRoute: '/first',
        getPages: [
          GetPage(page: () => const Text('first'), name: '/first'),
          GetPage(page: () => const Text('second'), name: '/second'),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(Get.defaultTransitionDuration, const Duration(milliseconds: 500));

    Get.toNamed('/second');
    // The push is processed one frame after toNamed; the second pump
    // starts the transition at the fake clock's current time.
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    // 350ms in: past the old hardcoded 300ms default, but the configured
    // 500ms transition must still be running.
    final route = Get.rawRoute as ModalRoute<dynamic>;
    expect(route.settings.name, '/second');
    expect(route.animation!.isCompleted, false);
    expect(route.animation!.value, greaterThan(0.0));

    await tester.pumpAndSettle();
    expect(route.animation!.isCompleted, true);
    expect(find.text('second'), findsOneWidget);
  });

  testWidgets('default transition duration stays 300ms when no app-level '
      'value is given', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        defaultTransition: Transition.cupertino,
        initialRoute: '/first',
        getPages: [
          GetPage(page: () => const Text('first'), name: '/first'),
          GetPage(page: () => const Text('second'), name: '/second'),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(Get.defaultTransitionDuration, const Duration(milliseconds: 300));

    Get.toNamed('/second');
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    final route = Get.rawRoute as ModalRoute<dynamic>;
    expect(route.settings.name, '/second');
    expect(route.animation!.isCompleted, true);

    await tester.pumpAndSettle();
    expect(find.text('second'), findsOneWidget);
  });
}
