import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

import 'utils/wrapper.dart';

class HomeController extends GetxController {
  static final instances = <HomeController>[];

  HomeController() {
    instances.add(this);
  }

  int inits = 0;
  int closes = 0;

  @override
  void onInit() {
    inits++;
    super.onInit();
  }

  @override
  void onClose() {
    closes++;
    super.onClose();
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(HomeController.new);
    Get.find<HomeController>();
    return const Center(child: Text('home'));
  }
}

class SecondView extends StatelessWidget {
  const SecondView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('second'));
  }
}

List<GetPage> _pages() => [
      GetPage(
        name: '/home',
        page: () => const HomeView(),
      ),
      // A distinct route that resolves the same controller type, so that
      // navigating between the two recreates the route (the router
      // delegate reuses a page with the same name, which would sidestep
      // the scenario under test).
      GetPage(
        name: '/other',
        page: () => const HomeView(),
      ),
      GetPage(
        name: '/second',
        page: () => const SecondView(),
      ),
    ];

void main() {
  setUp(HomeController.instances.clear);

  // Regression test for jonataslaw/getx#3351: `Get.offAllNamed` to a
  // route that registers the same controller type must not close or
  // unregister the freshly created controller when the old route
  // disposes.
  testWidgets(
      'offAllNamed to a route with the same controller keeps the new '
      'controller registered and open', (tester) async {
    await tester.pumpWidget(
      Wrapper(namedRoutes: _pages(), initialRoute: '/home'),
    );
    await tester.pumpAndSettle();

    expect(HomeController.instances.length, 1);
    final first = HomeController.instances.first;

    Get.toNamed('/second');
    await tester.pumpAndSettle();

    Get.offAllNamed('/other');
    await tester.pumpAndSettle();

    expect(find.byType(HomeView), findsOneWidget);
    expect(HomeController.instances.length, 2);
    final second = HomeController.instances.last;

    expect(first.closes, 1, reason: 'the old instance must be disposed');
    expect(second.closes, 0, reason: 'the new instance must stay open');
    expect(Get.isRegistered<HomeController>(), true);
    expect(identical(Get.find<HomeController>(), second), true);

    Get.reset();
  });

  // Regression test for jonataslaw/getx#3315 and #3446: re-navigating to
  // the same route while the previous instance of that route is still
  // playing its exit transition must leave the new route with a live,
  // registered controller whose onInit ran.
  testWidgets(
      're-pushing the same route during the exit transition keeps the new '
      'controller alive', (tester) async {
    await tester.pumpWidget(
      Wrapper(namedRoutes: _pages(), initialRoute: '/second'),
    );
    await tester.pumpAndSettle();

    Get.toNamed('/home');
    await tester.pumpAndSettle();

    expect(HomeController.instances.length, 1);
    final first = HomeController.instances.first;

    Get.back();
    // Pump a few frames only: the popped route is still mid-transition
    // and has not been disposed yet.
    await tester.pump(const Duration(milliseconds: 50));

    Get.toNamed('/home');
    await tester.pumpAndSettle();

    expect(find.byType(HomeView), findsOneWidget);
    expect(HomeController.instances.length, 2);
    final second = HomeController.instances.last;

    expect(second.inits, 1);
    expect(second.closes, 0);
    expect(first.closes, 1);
    expect(Get.isRegistered<HomeController>(), true);
    expect(identical(Get.find<HomeController>(), second), true);

    Get.reset();
  });
}
