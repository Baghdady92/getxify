// Regression test for upstream issues #1716, #3042 and #1381:
// Get.defaultDialog declared onCustom, textCustom and custom but never
// used them, so the custom action silently never showed up.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

import 'utils/wrapper.dart';

void main() {
  testWidgets("textCustom/onCustom render a tappable custom button", (
    tester,
  ) async {
    await tester.pumpWidget(Wrapper(child: Container()));
    await tester.pumpAndSettle();

    var customPressed = false;
    Get.defaultDialog(
      title: 'Dialog',
      middleText: 'message',
      textConfirm: 'Ok',
      textCustom: 'MyCustomAction',
      onCustom: () => customPressed = true,
    );
    await tester.pumpAndSettle();

    expect(find.text('MyCustomAction'), findsOneWidget);

    await tester.tap(find.text('MyCustomAction'));
    await tester.pumpAndSettle();

    expect(customPressed, isTrue);
    // Like the confirm button, the custom button does not auto-close.
    expect(Get.isDialogOpen, isTrue);
  });

  testWidgets("onCustom alone renders the default 'Custom' label", (
    tester,
  ) async {
    await tester.pumpWidget(Wrapper(child: Container()));
    await tester.pumpAndSettle();

    var customPressed = false;
    Get.defaultDialog(title: 'Dialog', onCustom: () => customPressed = true);
    await tester.pumpAndSettle();

    expect(find.text('Custom'), findsOneWidget);

    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();

    expect(customPressed, isTrue);
  });

  testWidgets("a custom widget is shown among the dialog actions", (
    tester,
  ) async {
    await tester.pumpWidget(Wrapper(child: Container()));
    await tester.pumpAndSettle();

    const customKey = Key('custom-action');
    Get.defaultDialog(
      title: 'Dialog',
      middleText: 'message',
      custom: ElevatedButton(
        key: customKey,
        onPressed: () {},
        child: const Text('FromWidget'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(customKey), findsOneWidget);
    expect(find.text('FromWidget'), findsOneWidget);
  });

  testWidgets("custom takes precedence over textCustom/onCustom", (
    tester,
  ) async {
    await tester.pumpWidget(Wrapper(child: Container()));
    await tester.pumpAndSettle();

    Get.defaultDialog(
      title: 'Dialog',
      custom: const Text('WidgetWins'),
      textCustom: 'ButtonLoses',
      onCustom: () {},
    );
    await tester.pumpAndSettle();

    expect(find.text('WidgetWins'), findsOneWidget);
    expect(find.text('ButtonLoses'), findsNothing);
  });
}
