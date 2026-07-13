// Regression tests for upstream issue #3261: GetPage.copyWith dropped
// preventDuplicateHandlingMode, so the mode set on a GetPage (or passed to
// Get.to) was reset to the default reorderRoutes before _push consulted it.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

import 'utils/wrapper.dart';

void main() {
  test('copyWith preserves preventDuplicateHandlingMode', () {
    final page = GetPage(
      name: '/a',
      page: () => const Text('a'),
      preventDuplicateHandlingMode: PreventDuplicateHandlingMode.doNothing,
    );

    expect(
      page.copyWith().preventDuplicateHandlingMode,
      PreventDuplicateHandlingMode.doNothing,
    );
    expect(
      page
          .copyWith(
            preventDuplicateHandlingMode: PreventDuplicateHandlingMode.recreate,
          )
          .preventDuplicateHandlingMode,
      PreventDuplicateHandlingMode.recreate,
    );
  });

  testWidgets('GetPage with doNothing ignores a duplicate navigation', (
    tester,
  ) async {
    await tester.pumpWidget(
      Wrapper(
        initialRoute: '/first',
        namedRoutes: [
          GetPage(name: '/first', page: () => const Text('first')),
          GetPage(
            name: '/keep',
            page: () => const Text('keep'),
            preventDuplicateHandlingMode:
                PreventDuplicateHandlingMode.doNothing,
          ),
          GetPage(name: '/second', page: () => const Text('second')),
        ],
      ),
    );
    await tester.pumpAndSettle();

    Get.toNamed('/keep');
    await tester.pumpAndSettle();
    Get.toNamed('/second');
    await tester.pumpAndSettle();

    // Duplicate navigation to '/keep': with doNothing the stack must stay
    // untouched instead of reordering '/keep' to the top.
    Get.toNamed('/keep');
    await tester.pumpAndSettle();

    final delegate = Get.rootController.rootDelegate;
    expect(delegate.activePages.map((e) => e.pageSettings?.name), [
      '/first',
      '/keep',
      '/second',
    ]);
    expect(find.text('second'), findsOneWidget);
  });

  testWidgets(
    'GetPage with popUntilOriginalRoute pops back to the original route',
    (tester) async {
      await tester.pumpWidget(
        Wrapper(
          initialRoute: '/first',
          namedRoutes: [
            GetPage(name: '/first', page: () => const Text('first')),
            GetPage(
              name: '/orig',
              page: () => const Text('orig'),
              preventDuplicateHandlingMode:
                  PreventDuplicateHandlingMode.popUntilOriginalRoute,
            ),
            GetPage(name: '/second', page: () => const Text('second')),
          ],
        ),
      );
      await tester.pumpAndSettle();

      Get.toNamed('/orig');
      await tester.pumpAndSettle();
      Get.toNamed('/second');
      await tester.pumpAndSettle();

      // Duplicate navigation to '/orig': the routes above the original
      // entry must be popped, keeping the original instance on top.
      Get.toNamed('/orig');
      await tester.pumpAndSettle();

      final delegate = Get.rootController.rootDelegate;
      expect(delegate.activePages.map((e) => e.pageSettings?.name), [
        '/first',
        '/orig',
      ]);
      expect(find.text('orig'), findsOneWidget);
    },
  );
}
