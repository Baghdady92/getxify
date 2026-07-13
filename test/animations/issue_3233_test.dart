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
  group('issue #3233 - BlurAnimation blurs the child, not the backdrop', () {
    testWidgets('BlurAnimation uses ImageFiltered instead of BackdropFilter', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _Wrapper(
          child: BlurAnimation(
            duration: const Duration(milliseconds: 100),
            delay: Duration.zero,
            begin: 0.0,
            end: 15.0,
            child: Container(width: 50, height: 50, color: Colors.red),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(BlurAnimation),
          matching: find.byType(ImageFiltered),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(BlurAnimation),
          matching: find.byType(BackdropFilter),
        ),
        findsNothing,
      );

      await tester.pumpAndSettle();
    });

    testWidgets('blur() extension applies the filter to the child', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _Wrapper(
          child: Container(
            width: 50,
            height: 50,
            color: Colors.red,
          ).blur(duration: const Duration(milliseconds: 100)),
        ),
      );

      expect(
        find.ancestor(
          of: find.byType(Container),
          matching: find.byType(ImageFiltered),
        ),
        findsOneWidget,
      );
      expect(find.byType(BackdropFilter), findsNothing);

      await tester.pumpAndSettle();
    });
  });

  group('issue #3233 - GetAnimatedBuilder honors updated configuration', () {
    testWidgets('updated tween is used when the animation is replayed', (
      WidgetTester tester,
    ) async {
      AnimationController? controller;

      Widget buildAnimation(double tweenEnd) {
        return _Wrapper(
          child: GetAnimatedBuilder<double>(
            duration: const Duration(milliseconds: 500),
            delay: Duration.zero,
            tween: Tween<double>(begin: 0.0, end: tweenEnd),
            idleValue: 0.0,
            onStart: (c) => controller = c,
            builder: (_, value, _) => Text(value.toStringAsFixed(2)),
            child: Container(),
          ),
        );
      }

      await tester.pumpWidget(buildAnimation(1.0));
      await tester.pumpAndSettle();
      expect(find.text('1.00'), findsOneWidget);

      await tester.pumpWidget(buildAnimation(2.0));
      controller!.forward(from: 0);
      await tester.pumpAndSettle();

      expect(find.text('2.00'), findsOneWidget);
    });

    testWidgets('updated duration is used when the animation is replayed', (
      WidgetTester tester,
    ) async {
      AnimationController? controller;

      Widget buildAnimation(Duration duration) {
        return _Wrapper(
          child: GetAnimatedBuilder<double>(
            duration: duration,
            delay: Duration.zero,
            tween: Tween<double>(begin: 0.0, end: 1.0),
            idleValue: 0.0,
            onStart: (c) => controller = c,
            builder: (_, value, _) => Text(value.toStringAsFixed(2)),
            child: Container(),
          ),
        );
      }

      await tester.pumpWidget(
        buildAnimation(const Duration(milliseconds: 500)),
      );
      await tester.pumpAndSettle();
      expect(find.text('1.00'), findsOneWidget);

      await tester.pumpWidget(
        buildAnimation(const Duration(milliseconds: 1000)),
      );
      controller!.forward(from: 0);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('0.50'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('1.00'), findsOneWidget);
    });

    testWidgets('rebuild with identical configuration does not replay', (
      WidgetTester tester,
    ) async {
      Widget buildAnimation() {
        return _Wrapper(
          child: GetAnimatedBuilder<double>(
            duration: const Duration(milliseconds: 500),
            delay: Duration.zero,
            tween: Tween<double>(begin: 0.0, end: 1.0),
            idleValue: 0.0,
            builder: (_, value, _) => Text(value.toStringAsFixed(2)),
            child: Container(),
          ),
        );
      }

      await tester.pumpWidget(buildAnimation());
      await tester.pumpAndSettle();
      expect(find.text('1.00'), findsOneWidget);

      await tester.pumpWidget(buildAnimation());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('1.00'), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });
}
