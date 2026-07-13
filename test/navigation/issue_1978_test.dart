import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

// Regression tests for https://github.com/jonataslaw/getx/issues/1978:
// the page rendered for a GetRouterOutlet's initialRoute was resolved with a
// bare route-tree match, bypassing the delegate middleware pipeline —
// GetMiddleware.redirectDelegate never ran for it.

class DelegateGuard extends GetMiddleware {
  static int calls = 0;

  @override
  RouteDecoder? redirectDelegate(RouteDecoder route) {
    calls++;
    return RouteDecoder.fromRoute('/home/allowed');
  }
}

class StopGuard extends GetMiddleware {
  @override
  RouteDecoder? redirectDelegate(RouteDecoder route) => null;
}

GetMaterialApp buildApp({required List<GetMiddleware> middlewares}) {
  return GetMaterialApp(
    initialRoute: '/home',
    getPages: [
      GetPage(
        name: '/home',
        page: () => Scaffold(
          body: GetRouterOutlet(
            anchorRoute: '/home',
            initialRoute: '/home/guarded',
          ),
        ),
        children: [
          GetPage(
            name: '/guarded',
            page: () => const Text('guarded-view'),
            middlewares: middlewares,
          ),
          GetPage(name: '/allowed', page: () => const Text('allowed-view')),
        ],
      ),
    ],
  );
}

void main() {
  setUp(() => DelegateGuard.calls = 0);
  tearDown(Get.reset);

  testWidgets('redirectDelegate runs for an outlet initialRoute', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp(middlewares: [DelegateGuard()]));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(DelegateGuard.calls, greaterThan(0));
    expect(find.text('allowed-view'), findsOneWidget);
    expect(find.text('guarded-view'), findsNothing);
  });

  testWidgets(
    'a middleware stopping the navigation degrades to the not-found page',
    (tester) async {
      await tester.pumpWidget(buildApp(middlewares: [StopGuard()]));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('guarded-view'), findsNothing);
      expect(find.text('Route not found'), findsOneWidget);
    },
  );
}
