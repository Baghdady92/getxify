import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

// Regression tests for https://github.com/jonataslaw/getx/issues/2107:
// the iOS back-swipe gesture could never pop between sibling routes inside
// a GetRouterOutlet. The outlet navigator rendered only the current tree
// branch, so after navigating from one sibling to another it contained a
// single route — and a route that is alone in its navigator (route.isFirst)
// never enables the pop gesture. The outlet now stacks the sibling pages of
// every history entry sharing its anchor (previous siblings stay mounted
// beneath, retaining their state), and a pop performed imperatively on the
// outlet navigator — the exact call the gesture's dragEnd makes — pops the
// matching history entry through GetDelegate.didRemoveOutletPage.

class Tab1View extends StatefulWidget {
  const Tab1View({super.key});

  static int initCount = 0;
  static int disposeCount = 0;

  static void resetCounters() {
    initCount = 0;
    disposeCount = 0;
  }

  @override
  State<Tab1View> createState() => _Tab1ViewState();
}

class _Tab1ViewState extends State<Tab1View> {
  @override
  void initState() {
    super.initState();
    Tab1View.initCount++;
  }

  @override
  void dispose() {
    Tab1View.disposeCount++;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Text('tab1-view');
  }
}

GetMaterialApp buildApp({String initialRoute = '/home/tab1'}) {
  return GetMaterialApp(
    initialRoute: initialRoute,
    getPages: [
      GetPage(
        name: '/home',
        participatesInRootNavigator: true,
        page: () => Scaffold(
          body: Column(
            children: [
              const Text('home-shell'),
              Expanded(
                child: GetRouterOutlet(
                  anchorRoute: '/home',
                  initialRoute: '/home/tab1',
                ),
              ),
            ],
          ),
        ),
        children: [
          GetPage(name: '/tab1', page: () => const Tab1View()),
          GetPage(name: '/tab2', page: () => const Text('tab2-view')),
          GetPage(
            name: '/products',
            page: () => const Text('products-view'),
            children: [
              GetPage(name: '/details', page: () => const Text('details-view')),
            ],
          ),
        ],
      ),
    ],
  );
}

NavigatorState outletNavigator() =>
    Get.nestedKey('/home')!.navigatorKey.currentState!;

Route<dynamic> topOutletRoute() {
  Route<dynamic>? top;
  outletNavigator().popUntil((route) {
    top = route;
    return true;
  });
  return top!;
}

void main() {
  setUp(Tab1View.resetCounters);
  tearDown(Get.reset);

  testWidgets(
    'navigating between sibling routes stacks them inside the outlet '
    '(previous sibling stays mounted, pop gesture no longer gated on isFirst)',
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('tab1-view'), findsOneWidget);
      expect(topOutletRoute().isFirst, isTrue);

      Get.rootController.rootDelegate.toNamed('/home/tab2');
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('tab2-view'), findsOneWidget);
      // The previous sibling is still mounted beneath the new one (offstage
      // under the opaque top route), retaining its state.
      expect(find.text('tab1-view', skipOffstage: false), findsOneWidget);
      expect(Tab1View.initCount, 1);
      expect(Tab1View.disposeCount, 0);
      // The exact #2107 gating condition: with a single route in the outlet
      // navigator, _isPopGestureEnabled bailed out at route.isFirst. The top
      // sibling now sits on a real stack.
      expect(topOutletRoute().isFirst, isFalse);
    },
  );

  testWidgets(
    'an imperative pop of the outlet navigator (back-gesture code path) '
    'pops the matching history entry and reveals the previous sibling',
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final delegate = Get.rootController.rootDelegate;
      var navigationCompleted = false;
      // ignore: unawaited_futures
      delegate
          .toNamed('/home/tab2')
          .then((_) => navigationCompleted = true);
      await tester.pumpAndSettle();
      expect(find.text('tab2-view'), findsOneWidget);
      expect(delegate.activePages.length, 2);
      expect(navigationCompleted, isFalse);

      // A completed back-swipe ends in GetBackGestureController.dragEnd,
      // which calls navigator.pop() on the outlet's own navigator.
      outletNavigator().pop();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('tab2-view'), findsNothing);
      expect(find.text('tab1-view'), findsOneWidget);
      // The history entry was popped along with the visual route...
      expect(delegate.activePages.length, 1);
      expect(delegate.currentConfiguration?.pageSettings?.name, '/home/tab1');
      // ...its navigation future resolved...
      expect(navigationCompleted, isTrue);
      // ...and the revealed sibling kept its state (it was never disposed).
      expect(Tab1View.initCount, 1);
      expect(Tab1View.disposeCount, 0);
    },
  );

  testWidgets(
    'a declarative back still works and does not double-pop '
    '(feedback-loop guard)',
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final delegate = Get.rootController.rootDelegate;
      delegate.toNamed('/home/tab2');
      await tester.pumpAndSettle();
      delegate.toNamed('/home/products');
      await tester.pumpAndSettle();
      expect(delegate.activePages.length, 3);
      expect(find.text('products-view'), findsOneWidget);

      // Removes the products entry from the history; the outlet navigator
      // then removes its route through a declarative page-list update, which
      // must NOT be reported back as a second pop.
      delegate.back();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('products-view'), findsNothing);
      expect(find.text('tab2-view'), findsOneWidget);
      expect(delegate.activePages.length, 2);
      expect(delegate.currentConfiguration?.pageSettings?.name, '/home/tab2');

      delegate.back();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('tab1-view'), findsOneWidget);
      expect(delegate.activePages.length, 1);
      expect(delegate.currentConfiguration?.pageSettings?.name, '/home/tab1');
    },
  );

  testWidgets(
    'a real back-swipe drag pops between outlet siblings',
    (tester) async {
      // The Cupertino transition tracks the drag with a horizontal slide
      // (the iOS behavior #2107 is about); the default test-platform zoom
      // transition does not engage the swipe even at the root navigator.
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/home/tab1',
          getPages: [
            GetPage(
              name: '/home',
              participatesInRootNavigator: true,
              page: () => Scaffold(
                body: GetRouterOutlet(
                  anchorRoute: '/home',
                  initialRoute: '/home/tab1',
                ),
              ),
              children: [
                GetPage(
                  name: '/tab1',
                  popGesture: true,
                  transition: Transition.cupertino,
                  page: () =>
                      const Scaffold(body: Center(child: Text('tab1-view'))),
                ),
                GetPage(
                  name: '/tab2',
                  popGesture: true,
                  transition: Transition.cupertino,
                  page: () =>
                      const Scaffold(body: Center(child: Text('tab2-view'))),
                ),
              ],
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final delegate = Get.rootController.rootDelegate;
      delegate.toNamed('/home/tab2');
      await tester.pumpAndSettle();
      expect(find.text('tab2-view'), findsOneWidget);
      expect(delegate.activePages.length, 2);

      // Drag the top sibling far past the midpoint and release: the page
      // must track the finger and the release must pop it.
      final gesture = await tester.startGesture(const Offset(200, 300));
      await gesture.moveBy(const Offset(300, 0));
      await tester.pump();
      expect(
        tester.getTopLeft(find.text('tab2-view')).dx,
        greaterThan(300),
        reason: 'the top sibling must track the drag',
      );
      await gesture.moveBy(const Offset(300, 0));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('tab2-view'), findsNothing);
      expect(find.text('tab1-view'), findsOneWidget);
      expect(delegate.activePages.length, 1);
      expect(delegate.currentConfiguration?.pageSettings?.name, '/home/tab1');
    },
  );

  testWidgets(
    'an imperative pop of a deep-linked branch (single history entry) '
    'shortens the branch instead of emptying the history',
    (tester) async {
      await tester.pumpWidget(buildApp(initialRoute: '/home/products/details'));
      await tester.pumpAndSettle();

      final delegate = Get.rootController.rootDelegate;
      expect(find.text('details-view'), findsOneWidget);
      expect(delegate.activePages.length, 1);
      // The deep-linked branch already forms a stack inside the outlet.
      expect(topOutletRoute().isFirst, isFalse);

      outletNavigator().pop();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('details-view'), findsNothing);
      expect(find.text('products-view'), findsOneWidget);
      // The only history entry survived with its tree branch shortened.
      expect(delegate.activePages.length, 1);
      expect(delegate.currentConfiguration?.route?.name, '/home/products');
    },
  );
}
