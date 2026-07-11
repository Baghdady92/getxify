// Regression tests for upstream issues #3319 and #3387:
// Get.close(result: ...) must forward the result to the Future returned
// by Get.bottomSheet / Get.dialog instead of completing it with null.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

import 'utils/wrapper.dart';

void main() {
  testWidgets("Get.close returns result to awaited bottomSheet", (
    tester,
  ) async {
    await tester.pumpWidget(Wrapper(child: Container()));
    await tester.pump();

    final future = Get.bottomSheet<String>(const Text('sheet'));
    await tester.pumpAndSettle();

    expect(find.text('sheet'), findsOneWidget);
    expect(Get.isBottomSheetOpen, true);

    Get.close(result: 'sheet result');
    await tester.pumpAndSettle();

    expect(await future, 'sheet result');
    expect(find.text('sheet'), findsNothing);
    expect(Get.isBottomSheetOpen, false);
  });

  testWidgets("Get.close returns result to awaited dialog", (tester) async {
    await tester.pumpWidget(Wrapper(child: Container()));
    await tester.pump();

    final future = Get.dialog<String>(const Text('dialog'));
    await tester.pumpAndSettle();

    expect(find.text('dialog'), findsOneWidget);
    expect(Get.isDialogOpen, true);

    Get.close(result: 'dialog result');
    await tester.pumpAndSettle();

    expect(await future, 'dialog result');
    expect(find.text('dialog'), findsNothing);
    expect(Get.isDialogOpen, false);
  });

  testWidgets("Get.close with closeAll false returns result", (tester) async {
    await tester.pumpWidget(Wrapper(child: Container()));
    await tester.pump();

    final future = Get.bottomSheet<String>(const Text('sheet'));
    await tester.pumpAndSettle();

    Get.close(closeAll: false, result: 'single result');
    await tester.pumpAndSettle();

    expect(await future, 'single result');
    expect(find.text('sheet'), findsNothing);
  });

  testWidgets("Get.close does not pop page routes when nothing is open", (
    tester,
  ) async {
    await tester.pumpWidget(Wrapper(child: const Text('page')));
    await tester.pump();

    Get.close(result: 'unused');
    await tester.pumpAndSettle();

    expect(find.text('page'), findsOneWidget);
  });
}
