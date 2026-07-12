import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

// Regression tests for https://github.com/jonataslaw/getx/issues/1883:
// a pop through GetDelegate played the forward/push animation instead of a
// pop animation whenever the pop surfaced to a navigator as a page
// *replacement* — the norm for nested GetRouterOutlet stacks, which render
// only the current tree branch — because the DefaultTransitionDelegate marks
// the incoming page for push and instantly completes the leaving page.
// Additionally, a PopMode.page pop of the only history entry pushed the
// parent branch ON TOP of the leaf instead of replacing the entry.

const _duration = Duration(milliseconds: 300);
const _halfway = Duration(milliseconds: 150);

/// Starts the transition triggered by a preceding navigation call and pumps
/// to its halfway point.
///
/// The delegate mutates its history in a microtask (first pump), the router
/// rebuild applies the page diff and starts the transition (second pump),
/// and newly inserted route content becomes visible on the following frame
/// (the halfway pump).
Future<void> pumpHalfwayThroughTransition(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
  await tester.pump(_halfway);
}

class Shell extends StatelessWidget {
  const Shell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text('shell-view'),
          Expanded(
            child: GetRouterOutlet(
              anchorRoute: '/home',
              initialRoute: '/home/first',
            ),
          ),
        ],
      ),
    );
  }
}

GetMaterialApp buildOutletApp() {
  return GetMaterialApp(
    initialRoute: '/home/first',
    getPages: [
      GetPage(
        name: '/home',
        participatesInRootNavigator: true,
        page: () => const Shell(),
        children: [
          GetPage(
            name: '/first',
            page: () => const Text('first-view'),
            transition: Transition.rightToLeft,
            transitionDuration: _duration,
          ),
          GetPage(
            name: '/second',
            page: () => const Text('second-view'),
            transition: Transition.rightToLeft,
            transitionDuration: _duration,
          ),
        ],
      ),
    ],
  );
}

GetMaterialApp buildNestedBranchApp() {
  return GetMaterialApp(
    initialRoute: '/home/details',
    getPages: [
      GetPage(
        name: '/home',
        page: () => const Text('home-view'),
        children: [
          GetPage(
            name: '/details',
            page: () => const Text('details-view'),
            transition: Transition.rightToLeft,
            transitionDuration: _duration,
          ),
        ],
      ),
    ],
  );
}

GetMaterialApp buildFlatApp() {
  return GetMaterialApp(
    initialRoute: '/a',
    getPages: [
      GetPage(name: '/a', page: () => const Text('a-view')),
      GetPage(
        name: '/b',
        page: () => const Text('b-view'),
        transition: Transition.rightToLeft,
        transitionDuration: _duration,
      ),
    ],
  );
}

void main() {
  tearDown(Get.reset);

  testWidgets(
    'popping inside a GetRouterOutlet plays the pop animation, not a push',
    (tester) async {
      await tester.pumpWidget(buildOutletApp());
      await tester.pumpAndSettle();
      expect(find.text('first-view'), findsOneWidget);

      Get.rootController.rootDelegate.toNamed('/home/second');
      await pumpHalfwayThroughTransition(tester);
      // Forward navigation still plays the forward animation inside the
      // outlet: the entering page is mid slide-in from the right.
      expect(find.text('second-view'), findsOneWidget);
      expect(tester.getTopLeft(find.text('second-view')).dx, greaterThan(1));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('second-view')).dx, lessThan(1));

      Get.rootController.rootDelegate.back();
      await pumpHalfwayThroughTransition(tester);
      // The pop surfaces to the outlet navigator as a replacement
      // ([second] -> [first]). Before the fix the leaving page was removed
      // instantly and the revealed page slid in with the forward animation.
      expect(
        find.text('second-view'),
        findsOneWidget,
        reason: 'the popped page must animate out instead of vanishing',
      );
      expect(
        tester.getTopLeft(find.text('second-view')).dx,
        greaterThan(1),
        reason: 'the popped page must be mid slide-out to the right',
      );
      expect(find.text('first-view'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('first-view')).dx,
        lessThan(1),
        reason: 'the revealed page must appear in place, not slide in',
      );

      await tester.pumpAndSettle();
      expect(find.text('second-view'), findsNothing);
      expect(find.text('first-view'), findsOneWidget);
    },
  );

  testWidgets(
    'PopMode.page pop of the only history entry replaces it with the '
    'parent branch and plays the pop animation',
    (tester) async {
      await tester.pumpWidget(buildNestedBranchApp());
      await tester.pumpAndSettle();
      final delegate = Get.rootController.rootDelegate;
      expect(find.text('details-view'), findsOneWidget);
      expect(delegate.activePages.length, 1);

      delegate.popRoute(popMode: PopMode.page);
      await pumpHalfwayThroughTransition(tester);
      // Before the fix the parent was PUSHED on top of the leaf (history
      // became [details, home]) and slid in with the forward animation.
      expect(find.text('details-view'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('details-view')).dx,
        greaterThan(1),
        reason: 'the popped leaf must be mid slide-out to the right',
      );
      expect(find.text('home-view'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('home-view')).dx,
        lessThan(1),
        reason: 'the revealed parent must appear in place, not slide in',
      );

      await tester.pumpAndSettle();
      expect(find.text('details-view'), findsNothing);
      expect(find.text('home-view'), findsOneWidget);
      expect(delegate.activePages.length, 1);
      expect(delegate.activePages.last.route?.name, '/home');
    },
  );

  testWidgets(
    'offNamed (a replacement not caused by a pop) keeps the forward '
    'push animation',
    (tester) async {
      await tester.pumpWidget(buildFlatApp());
      await tester.pumpAndSettle();
      expect(find.text('a-view'), findsOneWidget);

      Get.rootController.rootDelegate.offNamed('/b');
      await pumpHalfwayThroughTransition(tester);
      expect(find.text('b-view'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('b-view')).dx,
        greaterThan(1),
        reason: 'a replace-style navigation must still slide in',
      );

      await tester.pumpAndSettle();
      expect(find.text('a-view'), findsNothing);
      expect(find.text('b-view'), findsOneWidget);
    },
  );

  testWidgets('a genuine removal pop at the root still animates out', (
    tester,
  ) async {
    await tester.pumpWidget(buildFlatApp());
    await tester.pumpAndSettle();

    Get.rootController.rootDelegate.toNamed('/b');
    await tester.pumpAndSettle();
    expect(find.text('b-view'), findsOneWidget);

    Get.rootController.rootDelegate.back();
    await pumpHalfwayThroughTransition(tester);
    expect(find.text('b-view'), findsOneWidget);
    expect(tester.getTopLeft(find.text('b-view')).dx, greaterThan(1));
    expect(find.text('a-view'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('b-view'), findsNothing);
    expect(find.text('a-view'), findsOneWidget);
  });
}
