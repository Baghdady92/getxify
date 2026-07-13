import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

// Regression tests for https://github.com/jonataslaw/getx/issues/3336
// (and its duplicate #2011): navigating from a nested child to an unrelated
// top-level route removed the nested shell (a page marked with
// participatesInRootNavigator: true) from the root navigator, destroying its
// state and its nested navigator; popping back rebuilt it from scratch.

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  static int initCount = 0;
  static int disposeCount = 0;

  static void resetCounters() {
    initCount = 0;
    disposeCount = 0;
  }

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  @override
  void initState() {
    super.initState();
    HomeShell.initCount++;
  }

  @override
  void dispose() {
    HomeShell.disposeCount++;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text('home-shell'),
          Expanded(
            child: GetRouterOutlet(
              anchorRoute: '/home',
              initialRoute: '/home/login',
            ),
          ),
        ],
      ),
    );
  }
}

GetMaterialApp buildApp() {
  return GetMaterialApp(
    initialRoute: '/home/login',
    getPages: [
      GetPage(
        name: '/home',
        participatesInRootNavigator: true,
        page: () => const HomeShell(),
        children: [
          GetPage(name: '/login', page: () => const Text('login-view')),
          GetPage(name: '/news', page: () => const Text('news-view')),
        ],
      ),
      GetPage(name: '/setting', page: () => const Text('setting-view')),
    ],
  );
}

void main() {
  setUp(HomeShell.resetCounters);
  tearDown(Get.reset);

  testWidgets('nested shell renders its current child', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('home-shell'), findsOneWidget);
    expect(find.text('login-view'), findsOneWidget);
    expect(HomeShell.initCount, 1);
  });

  testWidgets(
    'pushing an unrelated top-level route keeps the nested shell mounted',
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      Get.rootController.rootDelegate.toNamed('/home/news');
      await tester.pumpAndSettle();
      expect(find.text('news-view'), findsOneWidget);

      Get.rootController.rootDelegate.toNamed('/setting');
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('setting-view'), findsOneWidget);
      // Before the fix the root navigator stack was derived only from the
      // current history entry's branch, so pushing /setting unmounted the
      // home shell (and its nested navigator) entirely.
      expect(HomeShell.disposeCount, 0);
      expect(HomeShell.initCount, 1);
    },
  );

  testWidgets('popping back to the nested shell restores its preserved child', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    Get.rootController.rootDelegate.toNamed('/home/news');
    await tester.pumpAndSettle();
    Get.rootController.rootDelegate.toNamed('/setting');
    await tester.pumpAndSettle();

    Get.rootController.rootDelegate.back();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // The nested navigator kept the child selected before /setting was
    // pushed; before the fix the shell was recreated and reset to its
    // initialRoute.
    expect(find.text('news-view'), findsOneWidget);
    expect(find.text('setting-view'), findsNothing);
    expect(HomeShell.initCount, 1);
    expect(HomeShell.disposeCount, 0);
  });
}
