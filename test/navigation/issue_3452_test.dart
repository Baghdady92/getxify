import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

void main() {
  testWidgets('GetPageRoute.canTransitionTo accepts a non-fullscreenDialog '
      'MaterialPageRoute (issue #3452)', (tester) async {
    final getRoute = GetPageRoute<void>(
      page: () => const Scaffold(body: Text('first')),
    );
    final materialRoute = MaterialPageRoute<void>(
      builder: (_) => const Scaffold(body: Text('second')),
    );
    final materialDialogRoute = MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => const Scaffold(body: Text('dialog')),
    );

    expect(getRoute.canTransitionTo(materialRoute), isTrue);
    expect(getRoute.canTransitionTo(materialDialogRoute), isFalse);
  });

  testWidgets('outgoing GetPageRoute animates (secondaryAnimation runs) when a '
      'MaterialPageRoute is pushed on top (issue #3452)', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const Scaffold(body: Text('second')),
                  ),
                );
              },
              child: const Text('push'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final firstRoute =
        ModalRoute.of(tester.element(find.text('push')))! as PageRoute<void>;
    expect(firstRoute.secondaryAnimation!.status, AnimationStatus.dismissed);

    await tester.tap(find.text('push'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Mid-transition the outgoing route's secondary animation must be
    // driven; if canTransitionTo rejects the MaterialPageRoute it stays
    // dismissed and the previous page appears frozen.
    expect(
      firstRoute.secondaryAnimation!.status,
      isNot(AnimationStatus.dismissed),
    );

    await tester.pumpAndSettle();
    expect(find.text('second'), findsOneWidget);
  });
}
