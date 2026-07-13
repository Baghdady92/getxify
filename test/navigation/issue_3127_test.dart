import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

import 'utils/wrapper.dart';

// https://github.com/jonataslaw/getx/issues/3127
// Get.dialog should expose a transitionBuilder so a custom animation can
// be used without dropping down to Get.generalDialog.
void main() {
  testWidgets('Get.dialog uses the provided custom transitionBuilder', (
    tester,
  ) async {
    await tester.pumpWidget(Wrapper(child: Container()));
    await tester.pump();

    var builderUsed = false;
    Get.dialog(
      const _DialogContent(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        builderUsed = true;
        return ScaleTransition(scale: animation, child: child);
      },
    );
    await tester.pumpAndSettle();

    expect(builderUsed, true);
    expect(find.byType(_DialogContent), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byType(_DialogContent),
        matching: find.byType(ScaleTransition),
      ),
      findsWidgets,
    );

    Get.closeDialog();
    await tester.pumpAndSettle();
  });

  testWidgets('Get.dialog keeps the default fade when no transitionBuilder '
      'is given', (tester) async {
    await tester.pumpWidget(Wrapper(child: Container()));
    await tester.pump();

    Get.dialog(const _DialogContent());
    await tester.pumpAndSettle();

    expect(
      find.ancestor(
        of: find.byType(_DialogContent),
        matching: find.byType(FadeTransition),
      ),
      findsWidgets,
    );

    Get.closeDialog();
    await tester.pumpAndSettle();
  });
}

class _DialogContent extends StatelessWidget {
  const _DialogContent();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 50, height: 50);
  }
}
