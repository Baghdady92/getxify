import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

import 'utils/wrapper.dart';

void main() {
  testWidgets("Get.bottomSheet smoke test", (tester) async {
    await tester.pumpWidget(Wrapper(child: Container()));

    await tester.pump();

    Get.bottomSheet(
      Wrap(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.music_note),
            title: const Text('Music'),
            onTap: () {},
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.music_note), findsOneWidget);
  });

  testWidgets("Get.bottomSheet close test", (tester) async {
    await tester.pumpWidget(Wrapper(child: Container()));

    await tester.pump();

    Get.bottomSheet(
      Wrap(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.music_note),
            title: const Text('Music'),
            onTap: () {},
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(Get.isBottomSheetOpen, true);

    Get.backLegacy();
    await tester.pumpAndSettle();

    expect(Get.isBottomSheetOpen, false);

    // expect(() => Get.bottomSheet(Container(), isScrollControlled: null),
    //     throwsAssertionError);

    // expect(() => Get.bottomSheet(Container(), isDismissible: null),
    //     throwsAssertionError);

    // expect(() => Get.bottomSheet(Container(), enableDrag: null),
    //     throwsAssertionError);

    await tester.pumpAndSettle();
  });

  testWidgets("Get.bottomSheet with all properties smoke test", (tester) async {
    await tester.pumpWidget(Wrapper(child: Container()));
    await tester.pump();

    Get.bottomSheet(
      const Text('Test BottomSheet'),
      backgroundColor: Colors.red,
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias,
      barrierColor: Colors.black54,
      ignoreSafeArea: false,
      isScrollControlled: true,
      useRootNavigator: true,
      isDismissible: false,
      enableDrag: false,
      enterBottomSheetDuration: const Duration(milliseconds: 100),
      exitBottomSheetDuration: const Duration(milliseconds: 100),
      curve: Curves.easeIn,
    );

    await tester.pumpAndSettle();
    expect(find.text('Test BottomSheet'), findsOneWidget);
    expect(Get.isBottomSheetOpen, true);

    Get.backLegacy();
    await tester.pumpAndSettle();
    expect(Get.isBottomSheetOpen, false);
  });
}
