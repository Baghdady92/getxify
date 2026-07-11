// Regression tests for upstream issue #3342:
// Get.close / Get.closeDialog / Get.closeBottomSheet must also close
// overlays opened with Flutter's native showDialog/showModalBottomSheet,
// which do not set GetX's routing flags.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

import 'utils/wrapper.dart';

void main() {
  testWidgets("Get.close closes a native showDialog dialog", (tester) async {
    await tester.pumpWidget(Wrapper(child: Container()));
    await tester.pump();

    showDialog(
      context: Get.context!,
      builder: (_) => const Text('native dialog'),
    );
    await tester.pumpAndSettle();
    expect(find.text('native dialog'), findsOneWidget);

    Get.close();
    await tester.pumpAndSettle();

    expect(find.text('native dialog'), findsNothing);
  });

  testWidgets("Get.closeDialog closes a native showDialog dialog", (
    tester,
  ) async {
    await tester.pumpWidget(Wrapper(child: Container()));
    await tester.pump();

    showDialog(
      context: Get.context!,
      builder: (_) => const Text('native dialog'),
    );
    await tester.pumpAndSettle();
    expect(find.text('native dialog'), findsOneWidget);

    Get.closeDialog();
    await tester.pumpAndSettle();

    expect(find.text('native dialog'), findsNothing);
  });

  testWidgets("Get.close closes a native showModalBottomSheet sheet", (
    tester,
  ) async {
    await tester.pumpWidget(Wrapper(child: Container()));
    await tester.pump();

    showModalBottomSheet(
      context: Get.context!,
      builder: (_) => const Text('native sheet'),
    );
    await tester.pumpAndSettle();
    expect(find.text('native sheet'), findsOneWidget);

    Get.close();
    await tester.pumpAndSettle();

    expect(find.text('native sheet'), findsNothing);
  });

  testWidgets("Get.closeBottomSheet closes a native sheet", (tester) async {
    await tester.pumpWidget(Wrapper(child: Container()));
    await tester.pump();

    showModalBottomSheet(
      context: Get.context!,
      builder: (_) => const Text('native sheet'),
    );
    await tester.pumpAndSettle();
    expect(find.text('native sheet'), findsOneWidget);

    Get.closeBottomSheet();
    await tester.pumpAndSettle();

    expect(find.text('native sheet'), findsNothing);
  });

  testWidgets("Get.closeBottomSheet does not close native dialogs", (
    tester,
  ) async {
    await tester.pumpWidget(Wrapper(child: Container()));
    await tester.pump();

    showDialog(
      context: Get.context!,
      builder: (_) => const Text('native dialog'),
    );
    await tester.pumpAndSettle();

    Get.closeBottomSheet();
    await tester.pumpAndSettle();

    expect(find.text('native dialog'), findsOneWidget);
  });
}
