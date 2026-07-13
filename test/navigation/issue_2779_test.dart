import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

class AuthRedirectMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return const RouteSettings(name: '/login');
  }
}

class ArgsRedirectMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return RouteSettings(name: '/login', arguments: {'callbackUrl': route});
  }
}

class StopDelegateMiddleware extends GetMiddleware {
  @override
  Future<RouteDecoder?> redirectDelegate(RouteDecoder route) async => null;
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('home'));
  }
}

class ProtectedScreen extends StatelessWidget {
  const ProtectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('protected'));
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('login'));
  }
}

GetMaterialApp buildApp({List<GetMiddleware>? protectedMiddlewares}) {
  return GetMaterialApp(
    initialRoute: '/',
    getPages: [
      GetPage(name: '/', page: () => const Home()),
      GetPage(
        name: '/protected',
        page: () => const ProtectedScreen(),
        middlewares: protectedMiddlewares ?? [AuthRedirectMiddleware()],
      ),
      GetPage(name: '/login', page: () => const LoginScreen()),
    ],
  );
}

void main() {
  tearDown(Get.reset);

  testWidgets('v4-style redirect() is honored by toNamed', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    Get.toNamed('/protected');
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(ProtectedScreen), findsNothing);
    expect(Get.currentRoute, '/login');
  });

  testWidgets('redirect() arguments reach the target route', (tester) async {
    await tester.pumpWidget(
      buildApp(protectedMiddlewares: [ArgsRedirectMiddleware()]),
    );
    await tester.pumpAndSettle();

    Get.toNamed('/protected');
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(Get.currentRoute, '/login');
    expect(Get.arguments, {'callbackUrl': '/protected'});
  });

  testWidgets('v4-style redirect() is honored by offAllNamed', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    Get.offAllNamed('/protected');
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(ProtectedScreen), findsNothing);
    expect(Get.currentRoute, '/login');
    expect(Get.rootController.rootDelegate.activePages.length, 1);
  });

  testWidgets(
    'a null redirectDelegate stops replace-style navigation (offAllNamed)',
    (tester) async {
      await tester.pumpWidget(
        buildApp(protectedMiddlewares: [StopDelegateMiddleware()]),
      );
      await tester.pumpAndSettle();

      Get.offAllNamed('/protected');
      await tester.pumpAndSettle();

      expect(find.byType(Home), findsOneWidget);
      expect(find.byType(ProtectedScreen), findsNothing);
      expect(Get.currentRoute, '/');
    },
  );
}
