import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

class _Wrapper extends StatelessWidget {
  const _Wrapper({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: child));
  }
}

void main() {
  group('issue #2760 - autoPlayOnUpdate replays animation on tween change', () {
    testWidgets('GetAnimatedBuilder replays from the beginning when the tween '
        'changes and autoPlayOnUpdate is true', (WidgetTester tester) async {
      Widget buildAnimation(double tweenEnd) {
        return _Wrapper(
          child: GetAnimatedBuilder<double>(
            duration: const Duration(milliseconds: 500),
            delay: Duration.zero,
            tween: Tween<double>(begin: 0.0, end: tweenEnd),
            idleValue: 0.0,
            autoPlayOnUpdate: true,
            builder: (_, value, _) => Text(value.toStringAsFixed(2)),
            child: Container(),
          ),
        );
      }

      await tester.pumpWidget(buildAnimation(1.0));
      await tester.pumpAndSettle();
      expect(find.text('1.00'), findsOneWidget);

      await tester.pumpWidget(buildAnimation(2.0));

      // The animation restarted from the beginning instead of snapping to
      // the new tween end.
      expect(find.text('0.00'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('1.00'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('2.00'), findsOneWidget);
    });

    testWidgets('rebuild with an identical tween does not replay even with '
        'autoPlayOnUpdate enabled', (WidgetTester tester) async {
      var buildCount = 0;

      Widget buildAnimation() {
        return _Wrapper(
          child: GetAnimatedBuilder<double>(
            duration: const Duration(milliseconds: 500),
            delay: Duration.zero,
            tween: Tween<double>(begin: 0.0, end: 1.0),
            idleValue: 0.0,
            autoPlayOnUpdate: true,
            builder: (_, value, _) {
              buildCount++;
              return Text(value.toStringAsFixed(2));
            },
            child: Container(),
          ),
        );
      }

      await tester.pumpWidget(buildAnimation());
      await tester.pumpAndSettle();
      expect(find.text('1.00'), findsOneWidget);
      expect(buildCount, greaterThan(0));

      await tester.pumpWidget(buildAnimation());
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('1.00'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('default behavior without autoPlayOnUpdate still snaps to '
        'the new tween end without replaying', (WidgetTester tester) async {
      Widget buildAnimation(double tweenEnd) {
        return _Wrapper(
          child: GetAnimatedBuilder<double>(
            duration: const Duration(milliseconds: 500),
            delay: Duration.zero,
            tween: Tween<double>(begin: 0.0, end: tweenEnd),
            idleValue: 0.0,
            builder: (_, value, _) => Text(value.toStringAsFixed(2)),
            child: Container(),
          ),
        );
      }

      await tester.pumpWidget(buildAnimation(1.0));
      await tester.pumpAndSettle();
      expect(find.text('1.00'), findsOneWidget);

      await tester.pumpWidget(buildAnimation(2.0));
      expect(find.text('2.00'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('scale() extension inside Obx replays when the observed '
        'value changes', (WidgetTester tester) async {
      final selected = false.obs;

      double currentScale() {
        final transform = tester.widget<Transform>(
          find
              .descendant(
                of: find.byType(ScaleAnimation),
                matching: find.byType(Transform),
              )
              .first,
        );
        // The x-axis scale factor of the Transform.scale matrix.
        return transform.transform.storage[0];
      }

      await tester.pumpWidget(
        _Wrapper(
          child: Obx(
            () => const FlutterLogo().scale(
              begin: 1.0,
              end: selected.value ? 0.5 : 1.0,
              duration: const Duration(milliseconds: 100),
              autoPlayOnUpdate: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(currentScale(), moreOrLessEquals(1.0));

      selected.value = true;
      // First pump delivers the Rx notification, second pump rebuilds the
      // Obx with the new tween.
      await tester.pump();
      await tester.pump();

      // Replay starts at the tween begin instead of snapping to the end.
      expect(currentScale(), moreOrLessEquals(1.0));

      await tester.pump(const Duration(milliseconds: 50));
      expect(currentScale(), moreOrLessEquals(0.75));

      await tester.pumpAndSettle();
      expect(currentScale(), moreOrLessEquals(0.5));
    });
  });
}
