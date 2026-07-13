import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

// https://github.com/jonataslaw/getx/issues/2122
// Arguments passed to Get.dialog were stored in the dialog route's
// settings but Get.arguments kept returning the underlying page's
// arguments, so the dialog could never read its own.
void main() {
  testWidgets('Get.arguments returns the dialog arguments while it is open '
      'and the page arguments after it closes', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/first',
        getPages: [
          GetPage(page: () => const Text('first'), name: '/first'),
          GetPage(page: () => const Text('second'), name: '/second'),
        ],
      ),
    );
    await tester.pumpAndSettle();

    Get.toNamed('/second', arguments: 'page arguments');
    await tester.pumpAndSettle();
    expect(Get.arguments, 'page arguments');

    Get.dialog(const Text('dialog'), arguments: 'dialog arguments');
    await tester.pumpAndSettle();

    expect(find.text('dialog'), findsOneWidget);
    expect(Get.arguments, 'dialog arguments');

    Get.closeDialog();
    await tester.pumpAndSettle();

    expect(Get.arguments, 'page arguments');
  });

  testWidgets('a dialog opened without arguments keeps exposing the page '
      'arguments', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/first',
        getPages: [
          GetPage(page: () => const Text('first'), name: '/first'),
          GetPage(page: () => const Text('second'), name: '/second'),
        ],
      ),
    );
    await tester.pumpAndSettle();

    Get.toNamed('/second', arguments: 'page arguments');
    await tester.pumpAndSettle();

    Get.dialog(const Text('dialog'));
    await tester.pumpAndSettle();

    expect(Get.arguments, 'page arguments');

    Get.closeDialog();
    await tester.pumpAndSettle();
  });
}
