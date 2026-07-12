import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

// https://github.com/jonataslaw/getx/issues/1969
// A controller registered while a dialog/bottom sheet is open used to be
// linked to the transient overlay route and was deleted as soon as the
// overlay closed. It must belong to the page under the overlay instead,
// and die with that page.
void main() {
  testWidgets('a controller put inside a dialog survives the dialog close '
      'and dies with the underlying page', (tester) async {
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

    Get.dialog(const _RegisteringDialog());
    await tester.pumpAndSettle();

    expect(Get.isRegistered<_SubController>(), true);

    Get.closeDialog();
    await tester.pumpAndSettle();

    // The dialog is gone but the page that owns the controller is not.
    expect(find.byType(_RegisteringDialog), findsNothing);
    expect(Get.isRegistered<_SubController>(), true);

    // Replacing the owning page finally disposes the controller.
    Get.offNamed('/second');
    await tester.pumpAndSettle();
    await tester.pump();

    expect(Get.isRegistered<_SubController>(), false);
  });

  testWidgets('a controller put inside a bottom sheet survives the sheet '
      'close and dies with the underlying page', (tester) async {
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

    Get.bottomSheet(const _RegisteringDialog());
    await tester.pumpAndSettle();

    expect(Get.isRegistered<_SubController>(), true);

    Get.closeBottomSheet();
    await tester.pumpAndSettle();

    expect(find.byType(_RegisteringDialog), findsNothing);
    expect(Get.isRegistered<_SubController>(), true);

    Get.offNamed('/second');
    await tester.pumpAndSettle();
    await tester.pump();

    expect(Get.isRegistered<_SubController>(), false);
  });
}

class _SubController extends GetxController {}

class _RegisteringDialog extends StatefulWidget {
  const _RegisteringDialog();

  @override
  State<_RegisteringDialog> createState() => _RegisteringDialogState();
}

class _RegisteringDialogState extends State<_RegisteringDialog> {
  @override
  void initState() {
    super.initState();
    Get.put(_SubController());
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 100, height: 100);
  }
}
