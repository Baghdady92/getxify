// Regression tests for upstream issues #2975 / #3054 / #3251:
// preventDuplicates was dead code in the Navigator 2.0 push pipeline —
// neither GetPage(preventDuplicates: false) nor the flag passed to
// Get.toNamed / Get.to could ever push a duplicate route.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

import 'utils/wrapper.dart';

class DupPage extends StatelessWidget {
  const DupPage({super.key});

  @override
  Widget build(BuildContext context) => const Text('dup');
}

void main() {
  testWidgets('GetPage(preventDuplicates: false) allows duplicate pushes', (
    tester,
  ) async {
    await tester.pumpWidget(
      Wrapper(
        initialRoute: '/first',
        namedRoutes: [
          GetPage(name: '/first', page: () => const Text('first')),
          GetPage(
            name: '/dup',
            page: () => const Text('dup'),
            preventDuplicates: false,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    Get.toNamed('/dup');
    await tester.pumpAndSettle();
    Get.toNamed('/dup');
    await tester.pumpAndSettle();

    final delegate = Get.rootController.rootDelegate;
    expect(delegate.activePages.map((e) => e.pageSettings?.name), [
      '/first',
      '/dup',
      '/dup',
    ]);

    // The duplicate instances must carry distinct page keys so the
    // navigator accepts both.
    final keys = delegate.activePages.map((e) => e.route?.key).toList();
    expect(keys.toSet().length, keys.length);

    // Popping the duplicate lands on the first '/dup' instance.
    Get.back();
    await tester.pumpAndSettle();
    expect(find.text('dup'), findsOneWidget);
    expect(delegate.activePages.length, 2);
    expect(delegate.activePages.last.pageSettings?.name, '/dup');
  });

  testWidgets('Get.toNamed(preventDuplicates: false) allows duplicates', (
    tester,
  ) async {
    await tester.pumpWidget(
      Wrapper(
        initialRoute: '/first',
        namedRoutes: [
          GetPage(name: '/first', page: () => const Text('first')),
          GetPage(name: '/second', page: () => const Text('second')),
        ],
      ),
    );
    await tester.pumpAndSettle();

    Get.toNamed('/second');
    await tester.pumpAndSettle();
    Get.toNamed('/second', preventDuplicates: false);
    await tester.pumpAndSettle();

    final delegate = Get.rootController.rootDelegate;
    expect(delegate.activePages.map((e) => e.pageSettings?.name), [
      '/first',
      '/second',
      '/second',
    ]);
  });

  testWidgets('Get.to(preventDuplicates: false) stacks the same page type', (
    tester,
  ) async {
    await tester.pumpWidget(const Wrapper(child: Text('home')));
    await tester.pumpAndSettle();

    Get.to(() => const DupPage(), preventDuplicates: false);
    await tester.pumpAndSettle();
    Get.to(() => const DupPage(), preventDuplicates: false);
    await tester.pumpAndSettle();

    final delegate = Get.rootController.rootDelegate;
    expect(delegate.activePages.length, 3);
    expect(find.byType(DupPage), findsOneWidget);

    Get.back();
    await tester.pumpAndSettle();
    expect(find.byType(DupPage), findsOneWidget);
    expect(delegate.activePages.length, 2);
  });

  testWidgets('duplicate prevention still applies by default', (tester) async {
    await tester.pumpWidget(
      Wrapper(
        initialRoute: '/first',
        namedRoutes: [
          GetPage(name: '/first', page: () => const Text('first')),
          GetPage(name: '/second', page: () => const Text('second')),
        ],
      ),
    );
    await tester.pumpAndSettle();

    Get.toNamed('/second');
    await tester.pumpAndSettle();
    Get.toNamed('/second');
    await tester.pumpAndSettle();

    final delegate = Get.rootController.rootDelegate;
    expect(delegate.activePages.map((e) => e.pageSettings?.name), [
      '/first',
      '/second',
    ]);
  });
}
