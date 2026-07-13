import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

class BlockingMiddleware extends GetMiddleware {
  @override
  Future<RouteDecoder?> redirectDelegate(RouteDecoder route) async => null;
}

class GuardedScreen extends StatelessWidget {
  const GuardedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('guarded'));
  }
}

class OtherScreen extends StatelessWidget {
  const OtherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('other'));
  }
}

void main() {
  tearDown(Get.reset);

  testWidgets(
    'initial route stopped by a middleware falls back to the not-found '
    'page instead of a permanently blank screen',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/guarded',
          getPages: [
            GetPage(
              name: '/guarded',
              page: () => const GuardedScreen(),
              middlewares: [BlockingMiddleware()],
            ),
            GetPage(name: '/other', page: () => const OtherScreen()),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(GuardedScreen), findsNothing);
      // The stack must never stay empty: the delegate falls back to its
      // not-found page so the app is not blank.
      expect(Get.rootController.rootDelegate.activePages, isNotEmpty);
      expect(find.text('Route not found'), findsOneWidget);
    },
  );

  testWidgets(
    'a middleware stopping an in-app navigation keeps the current page',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/other',
          getPages: [
            GetPage(
              name: '/guarded',
              page: () => const GuardedScreen(),
              middlewares: [BlockingMiddleware()],
            ),
            GetPage(name: '/other', page: () => const OtherScreen()),
          ],
        ),
      );
      await tester.pumpAndSettle();

      Get.toNamed('/guarded');
      await tester.pumpAndSettle();

      expect(find.byType(OtherScreen), findsOneWidget);
      expect(find.byType(GuardedScreen), findsNothing);
      expect(Get.currentRoute, '/other');
    },
  );
}
