// Regression tests for upstream issue #1237:
// Get.rawRoute must not become null after Get.offAllNamed. The navigator
// reports the removal of the superseded pages after the push of the new
// top page, and the bottom-most removed page has no previous route; that
// report must not clobber the current route with null.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

Route<dynamic>? rawRouteInOnInit;
bool onInitRan = false;

class SecondController extends GetxController {
  @override
  void onInit() {
    onInitRan = true;
    rawRouteInOnInit = Get.rawRoute;
    super.onInit();
  }
}

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('first'));
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('second'));
  }
}

GetMaterialApp buildApp() {
  return GetMaterialApp(
    initialRoute: '/first',
    getPages: [
      GetPage(name: '/first', page: () => const FirstPage()),
      GetPage(
        name: '/second',
        page: () {
          Get.put(SecondController());
          return const SecondPage();
        },
      ),
    ],
  );
}

void main() {
  setUp(() {
    rawRouteInOnInit = null;
    onInitRan = false;
  });
  tearDown(Get.reset);

  testWidgets('Get.rawRoute is not null after offAllNamed', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    Get.offAllNamed('/second');
    await tester.pumpAndSettle();

    expect(find.text('second'), findsOneWidget);
    expect(Get.rawRoute, isNotNull);
    expect(Get.rawRoute!.settings.name, '/second');
  });

  testWidgets(
    'Get.rawRoute observed from a controller onInit during offAllNamed '
    'is not null',
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      Get.offAllNamed('/second');
      await tester.pumpAndSettle();

      expect(onInitRan, isTrue);
      expect(rawRouteInOnInit, isNotNull);
    },
  );
}
