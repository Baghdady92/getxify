import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

/// Mirrors the issue's repro: the middleware requires a `tabUID` query
/// parameter and redirects to the same location with the parameter added.
/// The redirect can only settle when the parameters added by the redirect
/// are visible through `Get.parameters` on the next middleware pass.
class TabUidMiddleware extends GetMiddleware {
  int attempts = 0;
  String? seenTabUid;
  String? seenId;

  @override
  RouteSettings? redirect(String? route) {
    attempts++;
    if (attempts > 6) {
      // Safety valve: a stale-parameters regression would otherwise loop
      // forever; give up so the test fails with assertions instead of
      // hanging.
      return null;
    }
    seenId ??= Get.parameters['id'];
    final tabUid = Get.parameters['tabUID'];
    if (tabUid == null) {
      return const RouteSettings(name: '/page2/2333?tabUID=abc123');
    }
    seenTabUid = tabUid;
    return null;
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('home'));
  }
}

class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('page2'));
  }
}

void main() {
  tearDown(Get.reset);

  testWidgets(
    'parameters added by a middleware redirect are visible to the next '
    'middleware pass through Get.parameters',
    (tester) async {
      final middleware = TabUidMiddleware();
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/',
          getPages: [
            GetPage(name: '/', page: () => const Home()),
            GetPage(
              name: '/page2/:id',
              page: () => const Page2(),
              middlewares: [middleware],
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      Get.toNamed('/page2/2333');
      await tester.pumpAndSettle();

      // The middleware observed the path parameter of the in-flight
      // navigation and the query parameter added by its own redirect.
      expect(middleware.seenId, '2333');
      expect(middleware.seenTabUid, 'abc123');
      expect(middleware.attempts, lessThanOrEqualTo(6));

      // The navigation settled on the redirected location.
      expect(find.byType(Page2), findsOneWidget);
      expect(Get.parameters['id'], '2333');
      expect(Get.parameters['tabUID'], 'abc123');
    },
  );
}
