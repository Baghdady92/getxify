// Regression test for upstream issue #3322: the browser back button (a
// platform route report handled by GetDelegate.setNewRoutePath) with a
// Get.dialog or Get.bottomSheet open must close the overlay instead of
// popping the page it is anchored to.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

import 'utils/wrapper.dart';

/// Simulates the platform (browser back/forward button or a deep link)
/// reporting a new route to the app.
Future<void> simulatePlatformRoute(WidgetTester tester, String location) async {
  final message = const JSONMethodCodec().encodeMethodCall(
    MethodCall('pushRouteInformation', <String, dynamic>{
      'location': location,
      'state': null,
    }),
  );
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    'flutter/navigation',
    message,
    (_) {},
  );
}

void main() {
  testWidgets('platform back closes an open dialog instead of the page', (
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

    Get.dialog(const Text('my dialog'));
    await tester.pumpAndSettle();
    expect(find.text('my dialog'), findsOneWidget);

    final delegate = Get.rootController.rootDelegate;
    expect(delegate.activePages.length, 2);

    // Browser back: only the dialog must be dismissed.
    await simulatePlatformRoute(tester, '/first');
    await tester.pumpAndSettle();

    expect(find.text('my dialog'), findsNothing);
    expect(find.text('second'), findsOneWidget);
    expect(delegate.activePages.length, 2);
    expect(delegate.activePages.last.pageSettings?.name, '/second');

    // A further back press with no overlay open pops the page.
    await simulatePlatformRoute(tester, '/first');
    await tester.pumpAndSettle();

    expect(find.text('first'), findsOneWidget);
    expect(delegate.activePages.length, 1);
  });

  testWidgets('platform back closes stacked overlays one at a time', (
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

    Get.bottomSheet(const SizedBox(height: 100, child: Text('sheet')));
    await tester.pumpAndSettle();
    Get.dialog(const Text('my dialog'));
    await tester.pumpAndSettle();

    final delegate = Get.rootController.rootDelegate;

    await simulatePlatformRoute(tester, '/first');
    await tester.pumpAndSettle();
    expect(find.text('my dialog'), findsNothing);
    expect(find.text('sheet'), findsOneWidget);
    expect(delegate.activePages.length, 2);

    await simulatePlatformRoute(tester, '/first');
    await tester.pumpAndSettle();
    expect(find.text('sheet'), findsNothing);
    expect(find.text('second'), findsOneWidget);
    expect(delegate.activePages.length, 2);

    await simulatePlatformRoute(tester, '/first');
    await tester.pumpAndSettle();
    expect(find.text('first'), findsOneWidget);
    expect(delegate.activePages.length, 1);
  });
}
