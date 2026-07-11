import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

class ForwardArgumentsMiddleware extends GetMiddleware {
  @override
  Future<RouteDecoder?> redirectDelegate(RouteDecoder route) async {
    return RouteDecoder.fromRoute('/second', arguments: route.args);
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('home'));
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

  testWidgets('middleware redirect can forward the original arguments', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => const Home()),
          GetPage(
            name: '/first',
            page: () => const FirstScreen(),
            middlewares: [ForwardArgumentsMiddleware()],
          ),
          GetPage(name: '/second', page: () => const SecondScreen()),
        ],
      ),
    );

    Get.toNamed('/first', arguments: {'answer': 42});
    await tester.pumpAndSettle();

    expect(find.byType(SecondScreen), findsOneWidget);
    expect(Get.currentRoute, '/second');
    expect(Get.arguments, {'answer': 42});
  });

  testWidgets('arguments of the incoming route are visible in middleware', (
    tester,
  ) async {
    Object? seenArgs;
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => const Home()),
          GetPage(
            name: '/first',
            page: () => const FirstScreen(),
            middlewares: [_CaptureArgsMiddleware((args) => seenArgs = args)],
          ),
        ],
      ),
    );

    Get.toNamed('/first', arguments: 'payload');
    await tester.pumpAndSettle();

    expect(seenArgs, 'payload');
    expect(Get.arguments, 'payload');
  });
}

class _CaptureArgsMiddleware extends GetMiddleware {
  _CaptureArgsMiddleware(this.onArgs);

  final void Function(Object? args) onArgs;

  @override
  Future<RouteDecoder?> redirectDelegate(RouteDecoder route) async {
    onArgs(route.args);
    return route;
  }
}
