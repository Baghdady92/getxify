import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

// Regression tests for the residual part of
// https://github.com/jonataslaw/getx/issues/1978: the page rendered for a
// GetRouterOutlet's initialRoute is resolved during build, so an
// asynchronous GetMiddleware.redirectDelegate result was ignored entirely —
// the guarded page stayed visible no matter what the middleware decided.
// The full pipeline is now resolved out-of-band
// (GetDelegate.resolveOutletInitialPageAsync) and the outlet rebuilds with
// the resolved page.

class AsyncRedirectGuard extends GetMiddleware {
  static int calls = 0;

  @override
  Future<RouteDecoder?> redirectDelegate(RouteDecoder route) async {
    calls++;
    return RouteDecoder.fromRoute('/home/allowed');
  }
}

class AsyncStopGuard extends GetMiddleware {
  @override
  Future<RouteDecoder?> redirectDelegate(RouteDecoder route) async => null;
}

class AsyncPassGuard extends GetMiddleware {
  @override
  Future<RouteDecoder?> redirectDelegate(RouteDecoder route) async => route;
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
  setUp(() => AsyncRedirectGuard.calls = 0);
  tearDown(Get.reset);

  testWidgets(
    'an async redirectDelegate result is applied to an outlet initialRoute',
    (tester) async {
      await tester.pumpWidget(buildApp(middlewares: [AsyncRedirectGuard()]));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(AsyncRedirectGuard.calls, greaterThan(0));
      // Before the fix the async result was dropped and the guarded page
      // stayed visible.
      expect(find.text('allowed-view'), findsOneWidget);
      expect(find.text('guarded-view'), findsNothing);
    },
  );

  testWidgets('an async middleware stopping the navigation degrades to the '
      'not-found page', (tester) async {
    await tester.pumpWidget(buildApp(middlewares: [AsyncStopGuard()]));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('guarded-view'), findsNothing);
    expect(find.text('Route not found'), findsOneWidget);
  });

  testWidgets(
    'an async middleware keeping the route settles without a rebuild loop',
    (tester) async {
      await tester.pumpWidget(buildApp(middlewares: [AsyncPassGuard()]));
      // Would time out here if every resolution notified the delegate again.
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('guarded-view'), findsOneWidget);
    },
  );
}
