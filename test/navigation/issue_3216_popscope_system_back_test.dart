// Regression tests for upstream issues #3216 / #2996 / #2704 / #2869 /
// #2434 / #2188 / #3140:
// the system back button (GetDelegate.popRoute) must consult the top
// route's pop-veto surface (PopScope, WillPopScope, GetPage.canPop) before
// popping the page declaratively, mirroring NavigatorState.maybePop, and a
// blocked pop must fire onPopInvoked with didPop: false.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

import 'utils/wrapper.dart';

/// Simulates the Android system back button / predictive back gesture.
Future<void> simulateSystemBack(WidgetTester tester) async {
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    'flutter/navigation',
    const JSONMethodCodec().encodeMethodCall(const MethodCall('popRoute')),
    (_) {},
  );
}

void main() {
  testWidgets('system back is vetoed by PopScope(canPop: false)', (
    tester,
  ) async {
    final popInvocations = <bool>[];

    await tester.pumpWidget(
      Wrapper(
        initialRoute: '/home',
        namedRoutes: [
          GetPage(name: '/home', page: () => const Text('home')),
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
    expect(find.text('guarded'), findsOneWidget);

    await simulateSystemBack(tester);
    await tester.pumpAndSettle();

    // The page must survive and PopScope must observe the blocked attempt.
    expect(find.text('guarded'), findsOneWidget);
    expect(Get.currentRoute, '/guarded');
    expect(popInvocations, [false]);
  });

  testWidgets('system back still pops with PopScope(canPop: true)', (
    tester,
  ) async {
    await tester.pumpWidget(
      Wrapper(
        initialRoute: '/home',
        namedRoutes: [
          GetPage(name: '/home', page: () => const Text('home')),
          GetPage(
            name: '/open',
            page: () => const PopScope(canPop: true, child: Text('open')),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    Get.toNamed('/open');
    await tester.pumpAndSettle();
    expect(find.text('open'), findsOneWidget);

    await simulateSystemBack(tester);
    await tester.pumpAndSettle();

    expect(find.text('open'), findsNothing);
    expect(find.text('home'), findsOneWidget);
    expect(Get.currentRoute, '/home');
  });

  testWidgets('system back is vetoed by a WillPopScope returning false', (
    tester,
  ) async {
    var callbackRuns = 0;

    await tester.pumpWidget(
      Wrapper(
        initialRoute: '/home',
        namedRoutes: [
          GetPage(name: '/home', page: () => const Text('home')),
          GetPage(
            name: '/legacy',
            // ignore: deprecated_member_use
            page: () => WillPopScope(
              onWillPop: () async {
                callbackRuns++;
                return false;
              },
              child: const Text('legacy'),
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    Get.toNamed('/legacy');
    await tester.pumpAndSettle();

    await simulateSystemBack(tester);
    await tester.pumpAndSettle();

    expect(callbackRuns, 1);
    expect(find.text('legacy'), findsOneWidget);
    expect(Get.currentRoute, '/legacy');
  });

  testWidgets('system back is vetoed by GetPage(canPop: false)', (
    tester,
  ) async {
    await tester.pumpWidget(
      Wrapper(
        initialRoute: '/home',
        namedRoutes: [
          GetPage(name: '/home', page: () => const Text('home')),
          GetPage(
            name: '/locked',
            canPop: false,
            page: () => const Text('locked'),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    Get.toNamed('/locked');
    await tester.pumpAndSettle();

    await simulateSystemBack(tester);
    await tester.pumpAndSettle();

    expect(find.text('locked'), findsOneWidget);
    expect(Get.currentRoute, '/locked');
  });

  testWidgets('Get.back keeps Navigator.pop semantics and ignores PopScope', (
    tester,
  ) async {
    await tester.pumpWidget(
      Wrapper(
        initialRoute: '/home',
        namedRoutes: [
          GetPage(name: '/home', page: () => const Text('home')),
          GetPage(
            name: '/guarded',
            page: () => const PopScope(canPop: false, child: Text('guarded')),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    Get.toNamed('/guarded');
    await tester.pumpAndSettle();

    // Get.back is documented to pop unconditionally, like Navigator.pop.
    Get.back();
    await tester.pumpAndSettle();

    expect(find.text('guarded'), findsNothing);
    expect(find.text('home'), findsOneWidget);
  });
}
