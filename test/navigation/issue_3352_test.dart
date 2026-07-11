import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

class UnknownScreen extends StatelessWidget {
  const UnknownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('not found'));
  }
}

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('root'));
  }
}

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('second'));
  }
}

void main() {
  tearDown(Get.reset);

  test(
    'matchRoute does not treat a partial ancestor match as a full match',
    () {
      final tree = ParseRouteTree(routes: <GetPage>[]);
      tree.addRoutes([
        GetPage(name: '/', page: () => Container()),
        GetPage(name: '/second', page: () => Container()),
      ]);

      final match = tree.matchRoute('/unknown');
      expect(match.route, isNull);

      final nested = tree.matchRoute('/second/nowhere');
      expect(nested.route, isNull);

      // full matches keep working
      expect(tree.matchRoute('/').route?.name, '/');
      expect(tree.matchRoute('/second').route?.name, '/second');
    },
  );

  testWidgets(
    'unknownRoute is shown for unregistered names even when a "/" page exists',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/',
          unknownRoute: GetPage(
            name: '/notfound',
            page: () => const UnknownScreen(),
          ),
          getPages: [
            GetPage(name: '/', page: () => const RootScreen()),
            GetPage(name: '/second', page: () => const SecondScreen()),
          ],
        ),
      );

      Get.toNamed('/route-that-does-not-exist');
      await tester.pumpAndSettle();

      expect(find.byType(UnknownScreen), findsOneWidget);
      expect(find.byType(RootScreen), findsNothing);
      expect(Get.currentRoute, '/notfound');
    },
  );
}
