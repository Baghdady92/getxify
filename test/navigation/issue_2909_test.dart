import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

class NullOnPageCalledMiddleware extends GetMiddleware {
  @override
  GetPage? onPageCalled(GetPage? page) => null;
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('home'));
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('main'));
  }
}

void main() {
  tearDown(Get.reset);

  testWidgets(
    'onPageCalled returning null does not throw a null check error and '
    'degrades to the not-found page',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/',
          getPages: [
            GetPage(name: '/', page: () => const Home()),
            GetPage(
              name: '/main',
              page: () => const MainScreen(),
              middlewares: [NullOnPageCalledMiddleware()],
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      Get.offAllNamed('/main');
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(MainScreen), findsNothing);
      expect(find.text('Route not found'), findsOneWidget);
    },
  );

  testWidgets('onPageCalled returning null does not crash toNamed either', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => const Home()),
          GetPage(
            name: '/main',
            page: () => const MainScreen(),
            middlewares: [NullOnPageCalledMiddleware()],
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    Get.toNamed('/main');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(MainScreen), findsNothing);
  });
}
