import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

class CountingMiddleware extends GetMiddleware {
  int builtCount = 0;
  int disposeCount = 0;
  final guardedRoutes = <String?>[];

  @override
  RouteSettings? redirect(String? route) {
    guardedRoutes.add(route);
    return null;
  }

  @override
  Widget onPageBuilt(Widget page) {
    builtCount++;
    return page;
  }

  @override
  void onPageDispose() {
    disposeCount++;
  }
}

class ParentScreen extends StatelessWidget {
  const ParentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('parent'));
  }
}

class ChildScreen extends StatelessWidget {
  const ChildScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('child'));
  }
}

void main() {
  tearDown(Get.reset);

  testWidgets(
    'middleware lifecycle callbacks run once, on the declaring page only',
    (tester) async {
      final parentMiddleware = CountingMiddleware();
      final childMiddleware = CountingMiddleware();

      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/parent',
          getPages: [
            GetPage(
              name: '/parent',
              page: () => const ParentScreen(),
              middlewares: [parentMiddleware],
              children: [
                GetPage(
                  name: '/child',
                  page: () => const ChildScreen(),
                  middlewares: [childMiddleware],
                ),
              ],
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(parentMiddleware.builtCount, 1);
      expect(childMiddleware.builtCount, 0);

      Get.toNamed('/parent/child');
      await tester.pumpAndSettle();

      // The child page runs only its own lifecycle callbacks; the parent's
      // middleware must not fire a second time for the child's route.
      expect(find.byType(ChildScreen), findsOneWidget);
      expect(parentMiddleware.builtCount, 1);
      expect(childMiddleware.builtCount, 1);

      // Navigation guards, however, stay inherited: the parent middleware
      // was consulted for the child navigation.
      expect(parentMiddleware.guardedRoutes, contains('/parent/child'));

      Get.back();
      await tester.pumpAndSettle();

      // Disposing the child route disposes only the child's middleware.
      expect(childMiddleware.disposeCount, 1);
      expect(parentMiddleware.disposeCount, 0);
    },
  );

  test('nested pages register once and middlewares are never duplicated', () {
    final ma = CountingMiddleware();
    final mb = CountingMiddleware();
    final mc = CountingMiddleware();
    final tree = ParseRouteTree(routes: <GetPage>[]);
    tree.addRoute(
      GetPage(
        name: '/a',
        page: () => const ParentScreen(),
        middlewares: [ma],
        children: [
          GetPage(
            name: '/b',
            page: () => const ParentScreen(),
            middlewares: [mb],
            children: [
              GetPage(
                name: '/c',
                page: () => const ChildScreen(),
                middlewares: [mc],
              ),
            ],
          ),
        ],
      ),
    );

    expect(tree.routes.where((r) => r.name == '/a/b/c').length, 1);

    final middlewares = tree.matchRoute('/a/b/c').route!.middlewares;
    expect(middlewares.where((m) => identical(m, ma)).length, 1);
    expect(middlewares.where((m) => identical(m, mb)).length, 1);
    expect(middlewares.where((m) => identical(m, mc)).length, 1);

    // Only the middlewares declared on the page itself are its own.
    expect(tree.ownMiddlewaresOf('/a/b/c'), [mc]);
    expect(tree.ownMiddlewaresOf('/a/b'), [mb]);
    expect(tree.ownMiddlewaresOf('/a'), [ma]);
  });
}
