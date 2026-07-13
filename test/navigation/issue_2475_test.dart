// Regression test for https://github.com/jonataslaw/getx/issues/2475
//
// Get.to, Get.off and Get.offAll accept a [customTransition] that is
// forwarded through GetDelegate into the GetPage they build, so imperative
// navigation can use the same CustomTransition engine support that
// GetPage/named routes always had. This file fails to compile without the
// fix (no such named parameter), proving the additive API.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

import 'utils/wrapper.dart';

const _marker = ValueKey('custom-transition-marker');

class _MarkerTransition extends CustomTransition {
  int buildCount = 0;

  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    buildCount++;
    return KeyedSubtree(
      key: _marker,
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}

void main() {
  testWidgets('Get.to applies the given customTransition', (tester) async {
    final transition = _MarkerTransition();
    await tester.pumpWidget(const Wrapper(child: Text('home')));
    await tester.pumpAndSettle();

    expect(find.byKey(_marker, skipOffstage: false), findsNothing);

    Get.to(() => const Text('second'), customTransition: transition);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    // Mid transition the custom transition builder has been applied to the
    // incoming route.
    expect(transition.buildCount, greaterThan(0));
    expect(find.byKey(_marker, skipOffstage: false), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('second'), findsOneWidget);
    expect(find.byKey(_marker), findsOneWidget);
  });

  testWidgets('Get.off applies the given customTransition', (tester) async {
    final transition = _MarkerTransition();
    await tester.pumpWidget(const Wrapper(child: Text('home')));
    await tester.pumpAndSettle();

    expect(find.byKey(_marker, skipOffstage: false), findsNothing);

    Get.off(() => const Text('second'), customTransition: transition);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(transition.buildCount, greaterThan(0));
    expect(find.byKey(_marker, skipOffstage: false), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('second'), findsOneWidget);
    expect(find.byKey(_marker), findsOneWidget);
  });

  testWidgets('Get.offAll applies the given customTransition', (tester) async {
    final transition = _MarkerTransition();
    await tester.pumpWidget(const Wrapper(child: Text('home')));
    await tester.pumpAndSettle();

    expect(find.byKey(_marker, skipOffstage: false), findsNothing);

    Get.offAll(() => const Text('second'), customTransition: transition);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(transition.buildCount, greaterThan(0));
    expect(find.byKey(_marker, skipOffstage: false), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('second'), findsOneWidget);
    expect(find.byKey(_marker), findsOneWidget);
  });

  testWidgets('Get.to without customTransition keeps the default transition',
      (tester) async {
    await tester.pumpWidget(const Wrapper(child: Text('home')));
    await tester.pumpAndSettle();

    Get.to(() => const Text('second'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.byKey(_marker, skipOffstage: false), findsNothing);

    await tester.pumpAndSettle();
    expect(find.text('second'), findsOneWidget);
    expect(find.byKey(_marker, skipOffstage: false), findsNothing);
  });
}
