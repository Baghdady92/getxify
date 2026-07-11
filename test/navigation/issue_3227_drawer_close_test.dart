// Regression test for upstream issues #3227 and #2717:
// Get.back() and Get.close() must close an open Scaffold drawer instead of
// doing nothing (single page) or popping the whole page. Drawers are not
// routes: DrawerControllerState registers a LocalHistoryEntry on the
// enclosing page route, so the pop must go through the navigator, which
// consumes the entry and keeps the page.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

import 'utils/wrapper.dart';

class _DrawerPage extends StatelessWidget {
  const _DrawerPage({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      drawer: Drawer(child: Text('drawer of $label')),
      body: Text('body of $label'),
    );
  }
}

void main() {
  testWidgets("Get.back closes the drawer of the only page", (tester) async {
    await tester.pumpWidget(
      Wrapper(
        initialRoute: '/home',
        namedRoutes: [
          GetPage(name: '/home', page: () => const _DrawerPage(label: 'home')),
        ],
      ),
    );
    await tester.pumpAndSettle();

    tester.firstState<ScaffoldState>(find.byType(Scaffold)).openDrawer();
    await tester.pumpAndSettle();
    expect(find.text('drawer of home'), findsOneWidget);

    Get.back();
    await tester.pumpAndSettle();

    // The drawer must be closed and the page must survive.
    expect(find.text('drawer of home'), findsNothing);
    expect(find.text('body of home'), findsOneWidget);
    expect(Get.currentRoute, '/home');
  });

  testWidgets("Get.back closes the drawer first, then pops the page", (
    tester,
  ) async {
    await tester.pumpWidget(
      Wrapper(
        initialRoute: '/home',
        namedRoutes: [
          GetPage(name: '/home', page: () => const _DrawerPage(label: 'home')),
          GetPage(
            name: '/second',
            page: () => const _DrawerPage(label: 'second'),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    Get.toNamed('/second');
    await tester.pumpAndSettle();
    expect(find.text('body of second'), findsOneWidget);

    tester.firstState<ScaffoldState>(find.byType(Scaffold)).openDrawer();
    await tester.pumpAndSettle();
    expect(find.text('drawer of second'), findsOneWidget);

    Get.back();
    await tester.pumpAndSettle();

    // First back only closes the drawer.
    expect(find.text('drawer of second'), findsNothing);
    expect(find.text('body of second'), findsOneWidget);
    expect(Get.currentRoute, '/second');

    Get.back();
    await tester.pumpAndSettle();

    // Second back pops the page as usual.
    expect(find.text('body of home'), findsOneWidget);
    expect(Get.currentRoute, '/home');
  });

  testWidgets("Get.close closes an open drawer", (tester) async {
    await tester.pumpWidget(
      Wrapper(
        initialRoute: '/home',
        namedRoutes: [
          GetPage(name: '/home', page: () => const _DrawerPage(label: 'home')),
        ],
      ),
    );
    await tester.pumpAndSettle();

    tester.firstState<ScaffoldState>(find.byType(Scaffold)).openDrawer();
    await tester.pumpAndSettle();
    expect(find.text('drawer of home'), findsOneWidget);

    Get.close();
    await tester.pumpAndSettle();

    expect(find.text('drawer of home'), findsNothing);
    expect(find.text('body of home'), findsOneWidget);
    expect(Get.currentRoute, '/home');
  });

  testWidgets("Get.back still pops a dialog shown above an open drawer", (
    tester,
  ) async {
    await tester.pumpWidget(
      Wrapper(
        initialRoute: '/home',
        namedRoutes: [
          GetPage(name: '/home', page: () => const _DrawerPage(label: 'home')),
        ],
      ),
    );
    await tester.pumpAndSettle();

    tester.firstState<ScaffoldState>(find.byType(Scaffold)).openDrawer();
    await tester.pumpAndSettle();

    Get.dialog(const Text('dialog above drawer'));
    await tester.pumpAndSettle();
    expect(find.text('dialog above drawer'), findsOneWidget);

    Get.back();
    await tester.pumpAndSettle();

    // The dialog is topmost, so back closes it and leaves the drawer open.
    expect(find.text('dialog above drawer'), findsNothing);
    expect(find.text('drawer of home'), findsOneWidget);

    Get.back();
    await tester.pumpAndSettle();

    expect(find.text('drawer of home'), findsNothing);
    expect(find.text('body of home'), findsOneWidget);
  });
}
