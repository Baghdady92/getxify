// Regression tests for upstream issue #2899:
// Get.offAllNamed targeting the route that remains at the bottom of the
// stack must rebuild that page from scratch (recreating its bindings and
// controllers) instead of keeping the old route's stale content.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

int firstPageInitCount = 0;
int firstControllerInitCount = 0;

class FirstController extends GetxController {
  @override
  void onInit() {
    firstControllerInitCount++;
    super.onInit();
  }
}

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  void initState() {
    super.initState();
    firstPageInitCount++;
    Get.put(FirstController());
  }

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
      GetPage(name: '/second', page: () => const SecondPage()),
    ],
  );
}

void main() {
  setUp(() {
    firstPageInitCount = 0;
    firstControllerInitCount = 0;
  });
  tearDown(Get.reset);

  testWidgets('offAllNamed to the remaining bottom route recreates the page', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    expect(firstPageInitCount, 1);
    expect(firstControllerInitCount, 1);

    Get.toNamed('/second');
    await tester.pumpAndSettle();
    expect(find.text('second'), findsOneWidget);

    Get.offAllNamed('/first');
    await tester.pumpAndSettle();

    expect(find.text('first'), findsOneWidget);
    expect(Get.rootController.rootDelegate.activePages.length, 1);
    expect(firstPageInitCount, 2);
    expect(firstControllerInitCount, 2);
    expect(Get.isRegistered<FirstController>(), isTrue);
  });

  testWidgets('offAllNamed to a different route keeps single-build behavior', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    Get.toNamed('/second');
    await tester.pumpAndSettle();

    Get.offAllNamed('/second');
    await tester.pumpAndSettle();

    expect(find.text('second'), findsOneWidget);
    expect(Get.rootController.rootDelegate.activePages.length, 1);
  });
}
