import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

class RedirectToUnregisteredMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return const RouteSettings(name: '/route-that-is-not-registered');
  }
}

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('first'));
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

  testWidgets('middleware redirect to unregistered route without unknownRoute '
      'does not throw a null check error', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/second',
        getPages: [
          GetPage(
            name: '/first',
            page: () => const FirstScreen(),
            middlewares: [RedirectToUnregisteredMiddleware()],
          ),
          GetPage(name: '/second', page: () => const SecondScreen()),
        ],
      ),
    );

    Get.toNamed('/first');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // falls back to the delegate default not-found page
    expect(find.text('Route not found'), findsOneWidget);
    expect(find.byType(FirstScreen), findsNothing);
  });
}
