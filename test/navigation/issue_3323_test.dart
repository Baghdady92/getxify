import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('home'));
  }
}

class Second extends StatelessWidget {
  const Second({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('second'));
  }
}

void main() {
  tearDown(Get.reset);

  test('Get.key is accessible before GetRoot mounts and is stable', () {
    expect(() => Get.key, returnsNormally);
    expect(Get.key, same(Get.key));
  });

  test('APIs that require a mounted GetRoot still throw before mount', () {
    expect(() => Get.rootController.config, throwsException);
    expect(() => Get.rootController.rootDelegate, throwsException);
  });

  testWidgets('GetMaterialApp(navigatorKey: Get.key) builds and navigates', (
    tester,
  ) async {
    final GlobalKey<NavigatorState> preMountKey = Get.key;

    await tester.pumpWidget(
      GetMaterialApp(
        navigatorKey: preMountKey,
        getPages: [
          GetPage(name: '/', page: () => const Home()),
          GetPage(name: '/second', page: () => const Second()),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(Get.key, same(preMountKey));
    expect(preMountKey.currentState, isNotNull);

    Get.toNamed('/second');
    await tester.pumpAndSettle();

    expect(find.byType(Second), findsOneWidget);
  });

  testWidgets('Get.key keeps its identity across mount when not passed in', (
    tester,
  ) async {
    final GlobalKey<NavigatorState> preMountKey = Get.key;

    await tester.pumpWidget(
      GetMaterialApp(
        getPages: [GetPage(name: '/', page: () => const Home())],
      ),
    );
    await tester.pumpAndSettle();

    expect(Get.key, same(preMountKey));
    expect(Get.key.currentState, isNotNull);
  });
}
