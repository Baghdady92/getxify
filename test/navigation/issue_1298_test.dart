import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

final log = <String>[];

class RedirectPriorityMiddleware extends GetMiddleware {
  RedirectPriorityMiddleware(this.tag, {required super.priority, this.target});

  final String tag;
  final String? target;

  @override
  RouteSettings? redirect(String? route) {
    log.add(tag);
    return target == null ? null : RouteSettings(name: target);
  }
}

class DelegateOrderMiddleware extends GetMiddleware {
  DelegateOrderMiddleware(this.tag, {required super.priority});

  final String tag;

  @override
  FutureOr<RouteDecoder?> redirectDelegate(RouteDecoder route) {
    log.add(tag);
    return route;
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('home'));
  }
}

class MultiScreen extends StatelessWidget {
  const MultiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('multi'));
  }
}

class AScreen extends StatelessWidget {
  const AScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('a'));
  }
}

class BScreen extends StatelessWidget {
  const BScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('b'));
  }
}

void main() {
  setUp(log.clear);
  tearDown(Get.reset);

  testWidgets(
    'middlewares run in priority order and the first redirect wins',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/',
          getPages: [
            GetPage(name: '/', page: () => const Home()),
            GetPage(
              name: '/multi',
              page: () => const MultiScreen(),
              // Declared out of priority order on purpose.
              middlewares: [
                RedirectPriorityMiddleware('p5', priority: 5, target: '/b'),
                RedirectPriorityMiddleware('p1', priority: 1, target: '/a'),
              ],
            ),
            GetPage(name: '/a', page: () => const AScreen()),
            GetPage(name: '/b', page: () => const BScreen()),
          ],
        ),
      );
      await tester.pumpAndSettle();

      Get.toNamed('/multi');
      await tester.pumpAndSettle();

      // The lowest priority value runs first and its redirect stops the
      // chain, so p5 never runs and the navigation lands on '/a'.
      expect(log, ['p1']);
      expect(find.byType(AScreen), findsOneWidget);
      expect(find.byType(BScreen), findsNothing);
      expect(Get.currentRoute, '/a');
    },
  );

  testWidgets('redirectDelegate also runs in priority order', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => const Home()),
          GetPage(
            name: '/multi',
            page: () => const MultiScreen(),
            // Declared out of priority order on purpose.
            middlewares: [
              DelegateOrderMiddleware('d4', priority: 4),
              DelegateOrderMiddleware('d2', priority: 2),
            ],
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    Get.toNamed('/multi');
    await tester.pumpAndSettle();

    expect(log, ['d2', 'd4']);
    expect(find.byType(MultiScreen), findsOneWidget);
  });
}
