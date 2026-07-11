// Regression test for upstream issue #3121: on Flutter Web the browser
// back button arrives as a route information report handled by
// GetDelegate.setNewRoutePath, which must honor the top route's pop-veto
// surface (PopScope/WillPopScope/GetPage.canPop) when a single page would
// be popped.
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
  testWidgets('platform back is vetoed by PopScope(canPop: false)', (
    tester,
  ) async {
    final popInvocations = <bool>[];

    await tester.pumpWidget(
      Wrapper(
        initialRoute: '/first',
        namedRoutes: [
          GetPage(name: '/first', page: () => const Text('first')),
          GetPage(
            name: '/guarded',
            page: () => PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) =>
                  popInvocations.add(didPop),
              child: const Text('guarded'),
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    Get.toNamed('/guarded');
    await tester.pumpAndSettle();

    final delegate = Get.rootController.rootDelegate;
    expect(delegate.activePages.length, 2);

    await simulatePlatformRoute(tester, '/first');
    await tester.pumpAndSettle();

    // The page must survive, stay on the stack and observe the attempt.
    expect(find.text('guarded'), findsOneWidget);
    expect(delegate.activePages.length, 2);
    expect(delegate.activePages.last.pageSettings?.name, '/guarded');
    expect(popInvocations, [false]);
  });

  testWidgets('platform back still pops without a veto', (tester) async {
    await tester.pumpWidget(
      Wrapper(
        initialRoute: '/first',
        namedRoutes: [
          GetPage(name: '/first', page: () => const Text('first')),
          GetPage(
            name: '/open',
            page: () =>
                const PopScope(canPop: true, child: Text('open')),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    Get.toNamed('/open');
    await tester.pumpAndSettle();

    await simulatePlatformRoute(tester, '/first');
    await tester.pumpAndSettle();

    final delegate = Get.rootController.rootDelegate;
    expect(find.text('first'), findsOneWidget);
    expect(delegate.activePages.length, 1);
  });
}
