import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

// Regression tests for https://github.com/jonataslaw/getx/issues/2404:
// a controller created during a rebuild of a widget owned by a lower,
// still-mounted route (here: the root route's Obx swaps in HomePage while
// another route is topmost) was linked to the topmost route, so disposing
// that route deleted the controller the still-visible view depends on.

class RootController extends GetxController {
  final isLoggedIn = false.obs;
}

class HomePageController extends GetxController {
  static int closed = 0;

  @override
  void onClose() {
    closed++;
    super.onClose();
  }
}

class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Get.find<RootController>().isLoggedIn.value
          ? const HomePage()
          : const LandingPage();
    });
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Get.to(() => const SignUpPage(), routeName: '/sign-up');
          },
          child: const Text('Sign Up'),
        ),
      ),
    );
  }
}

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Swaps the root route's subtree to HomePage while this
                // route is topmost.
                Get.find<RootController>().isLoggedIn.value = true;
              },
              child: const Text('Log in'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.find<RootController>().isLoggedIn.value = true;
                Get.off(
                  () => const ConfirmationPage(),
                  routeName: '/confirmation',
                );
              },
              child: const Text('Finish Sign up'),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfirmationPage extends StatelessWidget {
  const ConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(onPressed: Get.back, child: const Text('Ok')),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomePageController>(
      init: HomePageController(),
      builder: (controller) {
        return const Scaffold(body: Center(child: Text('Home')));
      },
    );
  }
}

void main() {
  setUp(() {
    HomePageController.closed = 0;
  });
  tearDown(Get.reset);

  testWidgets(
    'controller created during a covered lower-route rebuild survives '
    'popping the topmost route',
    (tester) async {
      Get.put(RootController());

      await tester.pumpWidget(const GetMaterialApp(home: Root()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Flips the root route to HomePage: HomePageController is created in
      // a rebuild of the (covered) root route's subtree while '/sign-up'
      // is the current route.
      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();
      expect(Get.isRegistered<HomePageController>(), isTrue);

      // Popping '/sign-up' must not dispose HomePageController with it: the
      // root route's HomePage (still mounted, revealed by the pop) depends
      // on it.
      Get.back();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Home'), findsOneWidget);
      expect(HomePageController.closed, 0);
      expect(Get.isRegistered<HomePageController>(), isTrue);
    },
  );

  testWidgets(
    'controller created while the top route is being replaced survives the '
    'replacement and the later pop (issue repro flow)',
    (tester) async {
      Get.put(RootController());

      await tester.pumpWidget(const GetMaterialApp(home: Root()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Flips the root route to HomePage in the same frame in which
      // '/sign-up' is replaced by '/confirmation'.
      await tester.tap(find.text('Finish Sign up'));
      await tester.pumpAndSettle();
      expect(find.text('Ok'), findsOneWidget);
      expect(Get.isRegistered<HomePageController>(), isTrue);

      await tester.tap(find.text('Ok'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Home'), findsOneWidget);
      expect(HomePageController.closed, 0);
      expect(Get.isRegistered<HomePageController>(), isTrue);
    },
  );

  testWidgets('a popped route still disposes its own bound controller', (
    tester,
  ) async {
    Get.put(RootController());

    await tester.pumpWidget(
      GetMaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => const HomePage(), routeName: '/own-page');
                },
                child: const Text('go'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(Get.isRegistered<HomePageController>(), isTrue);

    Get.back();
    await tester.pumpAndSettle();

    // The controller belongs to the popped page (created by its own
    // GetBuilder): it must still be disposed with it.
    expect(Get.isRegistered<HomePageController>(), isFalse);
    expect(HomePageController.closed, 1);
  });
}
