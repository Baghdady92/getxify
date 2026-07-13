import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

import 'utils/wrapper.dart';

// https://github.com/jonataslaw/getx/issues/2474
// Get.back should report whether the back navigation actually happened,
// so callers (e.g. after a deep link landed on the only page in the
// stack) can detect the ignored back and navigate elsewhere instead.
void main() {
  testWidgets('Get.back returns false when there is nothing to go back to '
      'and true when it pops', (tester) async {
    await tester.pumpWidget(
      WrapperNamed(
        initialRoute: '/first',
        namedRoutes: [
          GetPage(page: () => const Text('first'), name: '/first'),
          GetPage(page: () => const Text('second'), name: '/second'),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('first'), findsOneWidget);

    // Only page in the stack: back must be a detectable no-op.
    final backOnRoot = Get.back();
    await tester.pumpAndSettle();

    expect(backOnRoot, false);
    expect(find.text('first'), findsOneWidget);

    Get.toNamed('/second');
    await tester.pumpAndSettle();
    expect(find.text('second'), findsOneWidget);

    final backFromSecond = Get.back();
    await tester.pumpAndSettle();

    expect(backFromSecond, true);
    expect(find.text('first'), findsOneWidget);
  });

  testWidgets('Get.back returns true when a local history entry handles '
      'the pop', (tester) async {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    await tester.pumpWidget(
      Wrapper(
        child: Scaffold(
          key: scaffoldKey,
          drawer: const Drawer(child: Text('drawer')),
          body: const Text('body'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    scaffoldKey.currentState!.openDrawer();
    await tester.pumpAndSettle();
    expect(find.text('drawer'), findsOneWidget);

    final handled = Get.back();
    await tester.pumpAndSettle();

    expect(handled, true);
    expect(find.text('drawer'), findsNothing);
    expect(find.text('body'), findsOneWidget);
  });
}
