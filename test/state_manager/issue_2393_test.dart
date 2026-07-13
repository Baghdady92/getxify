import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

class Issue2393Controller extends GetxController {
  int onInitCalls = 0;
  int onCloseCalls = 0;
  int counter = 0;

  @override
  void onInit() {
    onInitCalls++;
    super.onInit();
  }

  @override
  void onClose() {
    onCloseCalls++;
    super.onClose();
  }

  void increment() {
    counter++;
    update();
  }
}

/// Mimics the issue's responsive page: the tree shape around the
/// GetBuilder changes with the available width, so the old BindElement
/// cannot be reused and a new one is inflated while the page stays
/// visible.
class _ResponsivePage extends StatelessWidget {
  const _ResponsivePage();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final builder = GetBuilder<Issue2393Controller>(
          init: Issue2393Controller(),
          builder: (controller) => Text('counter: ${controller.counter}'),
        );
        if (constraints.maxWidth > 500) {
          return Row(children: [builder]);
        }
        return Scaffold(body: builder);
      },
    );
  }
}

void main() {
  testWidgets(
    'LayoutBuilder breakpoint swap does not delete the controller the '
    'still-visible page is using',
    (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MaterialApp(home: _ResponsivePage()));

      expect(find.text('counter: 0'), findsOneWidget);
      final controller = Get.find<Issue2393Controller>();
      expect(controller.onInitCalls, 1);

      // Cross the breakpoint: Scaffold -> Row swaps the element tree.
      tester.view.physicalSize = const Size(800, 800);
      await tester.pumpAndSettle();

      expect(find.text('counter: 0'), findsOneWidget);
      expect(
        Get.isRegistered<Issue2393Controller>(),
        isTrue,
        reason: 'the controller must survive the element swap',
      );
      expect(controller.onCloseCalls, 0);
      expect(controller.isClosed, isFalse);
      expect(Get.find<Issue2393Controller>(), same(controller));

      // The surviving element must still rebuild on update().
      controller.increment();
      await tester.pump();
      expect(find.text('counter: 1'), findsOneWidget);

      // Swap back across the breakpoint and verify again.
      tester.view.physicalSize = const Size(400, 800);
      await tester.pumpAndSettle();

      expect(find.text('counter: 1'), findsOneWidget);
      expect(controller.onCloseCalls, 0);

      // Once the page actually goes away, the deferred disposal runs.
      await tester.pumpWidget(const SizedBox());
      expect(Get.isRegistered<Issue2393Controller>(), isFalse);
      expect(controller.onCloseCalls, 1);
    },
  );

  testWidgets('single GetBuilder teardown still deletes its controller', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: GetBuilder<Issue2393Controller>(
          init: Issue2393Controller(),
          builder: (controller) => Text('counter: ${controller.counter}'),
        ),
      ),
    );

    final controller = Get.find<Issue2393Controller>();

    await tester.pumpWidget(const SizedBox());

    expect(Get.isRegistered<Issue2393Controller>(), isFalse);
    expect(controller.onCloseCalls, 1);
  });
}
