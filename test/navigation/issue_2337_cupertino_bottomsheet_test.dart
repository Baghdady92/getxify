// Regression test for upstream issue #2337:
// Get.bottomSheet threw "No MaterialLocalizations found" under
// GetCupertinoApp, which installs no material localization delegates.
// The sheet must fall back to DefaultMaterialLocalizations instead.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons, MaterialLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

void main() {
  testWidgets("Get.bottomSheet works inside GetCupertinoApp", (tester) async {
    await tester.pumpWidget(
      GetCupertinoApp(
        home: const CupertinoPageScaffold(child: Text('cupertino home')),
      ),
    );
    await tester.pumpAndSettle();

    // Sanity check: the app really has no MaterialLocalizations installed.
    expect(
      Localizations.of<MaterialLocalizations>(
        Get.context!,
        MaterialLocalizations,
      ),
      isNull,
    );

    Get.bottomSheet(
      const SizedBox(height: 200, child: Center(child: Icon(Icons.music_note))),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.music_note), findsOneWidget);
    expect(Get.isBottomSheetOpen, true);

    Get.back();
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.music_note), findsNothing);
    expect(Get.isBottomSheetOpen, false);
    expect(find.text('cupertino home'), findsOneWidget);
  });

  testWidgets("Get.bottomSheet under GetCupertinoApp is dismissible", (
    tester,
  ) async {
    await tester.pumpWidget(
      GetCupertinoApp(
        home: const CupertinoPageScaffold(child: Text('cupertino home')),
      ),
    );
    await tester.pumpAndSettle();

    Get.bottomSheet(
      const SizedBox(height: 200, child: Center(child: Text('sheet'))),
    );
    await tester.pumpAndSettle();
    expect(find.text('sheet'), findsOneWidget);

    // Tap the barrier above the sheet to dismiss it.
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    expect(find.text('sheet'), findsNothing);
    expect(Get.isBottomSheetOpen, false);
  });
}
