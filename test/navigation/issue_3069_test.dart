// Regression test for https://github.com/jonataslaw/getx/issues/3069
//
// GetSnackBar used physical EdgeInsets.only(left:, right:) for the
// title/message and action-button paddings, so under RTL the small
// icon-adjacent inset ended up on the wrong physical side, doubling the
// visual gap between the icon and the text.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

void main() {
  Widget buildApp(TextDirection direction) {
    return MaterialApp(
      home: Directionality(
        textDirection: direction,
        child: const Scaffold(
          body: GetSnackBar(
            title: 'ttl',
            message: 'msg',
            icon: Icon(Icons.info_outline),
            mainButton: TextButton(onPressed: null, child: Text('act')),
          ),
        ),
      ),
    );
  }

  EdgeInsets resolvedPaddingOf(
    WidgetTester tester,
    Finder inner,
    TextDirection direction,
  ) {
    final padding = tester.widget<Padding>(
      find.ancestor(of: inner, matching: find.byType(Padding)).first,
    );
    return padding.padding.resolve(direction);
  }

  testWidgets('LTR: icon-adjacent inset stays on the left', (tester) async {
    await tester.pumpWidget(buildApp(TextDirection.ltr));
    await tester.pump();

    final title = resolvedPaddingOf(tester, find.text('ttl'), TextDirection.ltr);
    final message =
        resolvedPaddingOf(tester, find.text('msg'), TextDirection.ltr);
    final button = resolvedPaddingOf(
        tester, find.byType(TextButton), TextDirection.ltr);

    // The icon sits at the start of the row (physical left in LTR), so the
    // small 4.0 inset must be on the left and the 8.0 action-side inset on
    // the right.
    expect(title.left, 4.0);
    expect(title.right, 8.0);
    expect(message.left, 4.0);
    expect(message.right, 8.0);
    expect(button.right, 4.0);
    expect(button.left, 0.0);
  });

  testWidgets('RTL: icon-adjacent inset mirrors to the right', (tester) async {
    await tester.pumpWidget(buildApp(TextDirection.rtl));
    await tester.pump();

    final title = resolvedPaddingOf(tester, find.text('ttl'), TextDirection.rtl);
    final message =
        resolvedPaddingOf(tester, find.text('msg'), TextDirection.rtl);
    final button = resolvedPaddingOf(
        tester, find.byType(TextButton), TextDirection.rtl);

    // The icon sits at the start of the row (physical right in RTL), so the
    // small 4.0 inset must mirror to the right and the 8.0 action-side inset
    // to the left.
    expect(title.right, 4.0);
    expect(title.left, 8.0);
    expect(message.right, 4.0);
    expect(message.left, 8.0);
    expect(button.left, 4.0);
    expect(button.right, 0.0);
  });
}
