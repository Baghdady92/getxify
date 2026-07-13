// Regression test for https://github.com/jonataslaw/getx/issues/2747
//
// The left bar indicator (and the progress indicator strip) bled over the
// snackbar's rounded corners because the content was never clipped to the
// background's borderRadius.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

void main() {
  testWidgets('left bar indicator is clipped to the borderRadius', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GetSnackBar(
            message: 'msg',
            leftBarIndicatorColor: Colors.red,
            borderRadius: 12.0,
          ),
        ),
      ),
    );
    // Extra pump so the post-frame callback delivers the background box size
    // and the left bar indicator is built.
    await tester.pump();
    await tester.pump();

    final clip = find.descendant(
      of: find.byType(GetSnackBar),
      matching: find.byType(ClipRRect),
    );
    expect(clip, findsOneWidget);
    expect(
      tester.widget<ClipRRect>(clip).borderRadius,
      BorderRadius.circular(12.0),
    );

    // The left bar indicator must be inside the clipped area.
    final indicator = find.byWidgetPredicate(
      (widget) => widget is Container && widget.color == Colors.red,
    );
    expect(find.descendant(of: clip, matching: indicator), findsOneWidget);
  });

  testWidgets('no clip is added when borderRadius is zero', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GetSnackBar(message: 'msg', leftBarIndicatorColor: Colors.red),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(
      find.descendant(
        of: find.byType(GetSnackBar),
        matching: find.byType(ClipRRect),
      ),
      findsNothing,
    );
  });
}
