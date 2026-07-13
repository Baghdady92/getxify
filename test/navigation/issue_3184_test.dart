import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

import 'utils/wrapper.dart';

// https://github.com/jonataslaw/getx/issues/3184
// Get.defaultDialog should accept a canPop argument that blocks the
// system back gesture/button from dismissing the dialog.
void main() {
  testWidgets('defaultDialog canPop: false blocks the back gesture/button', (
    tester,
  ) async {
    await tester.pumpWidget(Wrapper(child: Container()));
    await tester.pump();

    Get.defaultDialog(middleText: 'protected dialog', canPop: false);
    await tester.pumpAndSettle();

    expect(find.text('protected dialog'), findsOneWidget);
    expect(Get.isDialogOpen, true);

    // Simulates the system back button/gesture. maybePop returns true
    // because the blocked pop counts as handled, so the dialog staying
    // open is what proves the veto.
    await Get.key.currentState!.maybePop();
    await tester.pumpAndSettle();

    expect(find.text('protected dialog'), findsOneWidget);
    expect(Get.isDialogOpen, true);

    // The dialog can still be closed programmatically.
    Get.closeDialog();
    await tester.pumpAndSettle();

    expect(find.text('protected dialog'), findsNothing);
    expect(Get.isDialogOpen, false);
  });

  testWidgets('defaultDialog canPop: false still reports pop attempts '
      'through onWillPop', (tester) async {
    await tester.pumpWidget(Wrapper(child: Container()));
    await tester.pump();

    bool? reportedDidPop;
    Get.defaultDialog(
      middleText: 'protected dialog',
      canPop: false,
      onWillPop: (didPop, result) => reportedDidPop = didPop,
    );
    await tester.pumpAndSettle();

    await Get.key.currentState!.maybePop();
    await tester.pumpAndSettle();

    expect(reportedDidPop, false);
    expect(find.text('protected dialog'), findsOneWidget);

    Get.closeDialog();
    await tester.pumpAndSettle();
  });

  testWidgets('defaultDialog default keeps back dismissal working', (
    tester,
  ) async {
    await tester.pumpWidget(Wrapper(child: Container()));
    await tester.pump();

    Get.defaultDialog(middleText: 'dismissible dialog');
    await tester.pumpAndSettle();

    expect(find.text('dismissible dialog'), findsOneWidget);

    final popped = await Get.key.currentState!.maybePop();
    await tester.pumpAndSettle();

    expect(popped, true);
    expect(find.text('dismissible dialog'), findsNothing);
    expect(Get.isDialogOpen, false);
  });
}
