import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

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

  testWidgets(
    'initialRoute is honored on startup even when a "/" page is registered',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/second',
          getPages: [
            GetPage(name: '/', page: () => const RootScreen()),
            GetPage(name: '/second', page: () => const SecondScreen()),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SecondScreen), findsOneWidget);
      expect(find.byType(RootScreen), findsNothing);
      expect(Get.currentRoute, '/second');
    },
  );

  testWidgets('the registered "/" page stays reachable after startup', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/second',
        getPages: [
          GetPage(name: '/', page: () => const RootScreen()),
          GetPage(name: '/second', page: () => const SecondScreen()),
        ],
      ),
    );
    await tester.pumpAndSettle();

    Get.toNamed('/');
    await tester.pumpAndSettle();

    expect(find.byType(RootScreen), findsOneWidget);
    expect(Get.currentRoute, '/');
  });

  testWidgets('an initialRoute of "/" keeps resolving the "/" page', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => const RootScreen()),
          GetPage(name: '/second', page: () => const SecondScreen()),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(RootScreen), findsOneWidget);
    expect(Get.currentRoute, '/');
  });
}
