// Regression tests for upstream issue #3244:
// A single tester.pumpWidget of a GetMaterialApp must already render the
// initial page (v4 behavior), instead of requiring an extra pump for the
// router to asynchronously resolve the initial route.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('home'));
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('login'));
  }
}

class RedirectMiddleware extends GetMiddleware {
  @override
  Future<RouteDecoder?> redirectDelegate(RouteDecoder route) async {
    return RouteDecoder.fromRoute('/login');
  }
}

void main() {
  tearDown(Get.reset);

  testWidgets('home is rendered after a single pumpWidget', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: HomePage()));

    expect(find.text('home'), findsOneWidget);

    // Flushes the zero-duration onReady future scheduled by GetRoot, which
    // would otherwise be reported as a pending timer when the test ends.
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('the initial route is rendered after a single pumpWidget', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/home',
        getPages: [
          GetPage(name: '/home', page: () => const HomePage()),
          GetPage(name: '/login', page: () => const LoginPage()),
        ],
      ),
    );

    expect(find.text('home'), findsOneWidget);

    // Flushes the zero-duration onReady future scheduled by GetRoot, which
    // would otherwise be reported as a pending timer when the test ends.
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('a middleware redirect on the initial route still resolves', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/home',
        getPages: [
          GetPage(
            name: '/home',
            page: () => const HomePage(),
            middlewares: [RedirectMiddleware()],
          ),
          GetPage(name: '/login', page: () => const LoginPage()),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('login'), findsOneWidget);
    expect(find.text('home'), findsNothing);
  });
}
