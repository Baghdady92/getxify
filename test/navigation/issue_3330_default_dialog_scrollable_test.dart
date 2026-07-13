// Regression test for upstream issue #3330:
// Get.defaultDialog must expose AlertDialog's scrollable property so that
// tall content scrolls instead of overflowing.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

import 'utils/wrapper.dart';

void main() {
  testWidgets("Get.defaultDialog forwards scrollable to AlertDialog", (
    tester,
  ) async {
    await tester.pumpWidget(Wrapper(child: Container()));
    await tester.pump();

    Get.defaultDialog(
      scrollable: true,
      onConfirm: () {},
      content: const SizedBox(height: 2000, width: 50),
    );
    await tester.pumpAndSettle();

    final alertDialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
    expect(alertDialog.scrollable, true);
    expect(tester.takeException(), isNull);
  });

  testWidgets("Get.defaultDialog is not scrollable by default", (tester) async {
    await tester.pumpWidget(Wrapper(child: Container()));
    await tester.pump();

    Get.defaultDialog(onConfirm: () {});
    await tester.pumpAndSettle();

    final alertDialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
    expect(alertDialog.scrollable, false);
  });
}
