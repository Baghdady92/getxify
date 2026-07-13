import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

class Issue2123Controller extends GetxController {
  int onInitCalls = 0;
  int onCloseCalls = 0;

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
}

class _TogglePage extends StatefulWidget {
  const _TogglePage({required this.controller, this.autoRemove = true});

  final Issue2123Controller controller;
  final bool autoRemove;

  @override
  State<_TogglePage> createState() => _TogglePageState();
}

class _TogglePageState extends State<_TogglePage> {
  bool showBuilder = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () => setState(() => showBuilder = !showBuilder),
          child: const Text('toggle'),
        ),
        if (showBuilder)
          GetBuilder<Issue2123Controller>(
            global: false,
            autoRemove: widget.autoRemove,
            init: widget.controller,
            builder: (controller) => const Text('local builder'),
          ),
      ],
    );
  }
}

void main() {
  testWidgets(
    'GetBuilder(global: false) controller receives onClose exactly once '
    'when the widget is removed from the tree',
    (tester) async {
      final controller = Issue2123Controller();

      await tester.pumpWidget(
        MaterialApp(home: _TogglePage(controller: controller)),
      );

      expect(find.text('local builder'), findsOneWidget);
      expect(controller.onInitCalls, 1);
      expect(controller.onCloseCalls, 0);
      expect(
        Get.isRegistered<Issue2123Controller>(),
        isFalse,
        reason: 'a non-global controller must not enter the DI registry',
      );

      await tester.tap(find.text('toggle'));
      await tester.pumpAndSettle();

      expect(find.text('local builder'), findsNothing);
      expect(controller.onCloseCalls, 1);
      expect(controller.isClosed, isTrue);
    },
  );

  testWidgets(
    'GetBuilder(global: false) controller receives onClose when the whole '
    'app is torn down',
    (tester) async {
      final controller = Issue2123Controller();

      await tester.pumpWidget(
        MaterialApp(
          home: GetBuilder<Issue2123Controller>(
            global: false,
            init: controller,
            builder: (controller) => const Text('local builder'),
          ),
        ),
      );

      expect(controller.onInitCalls, 1);

      await tester.pumpWidget(const SizedBox());

      expect(controller.onCloseCalls, 1);
    },
  );

  testWidgets(
    'GetBuilder(global: false, autoRemove: false) does not close the '
    'controller on unmount',
    (tester) async {
      final controller = Issue2123Controller();

      await tester.pumpWidget(
        MaterialApp(
          home: _TogglePage(controller: controller, autoRemove: false),
        ),
      );

      await tester.tap(find.text('toggle'));
      await tester.pumpAndSettle();

      expect(controller.onCloseCalls, 0);
      expect(controller.isClosed, isFalse);

      controller.onDelete();
      expect(controller.onCloseCalls, 1);
    },
  );

  testWidgets(
    'GetBuilder(global: false) with the same controller instance in two '
    'builders closes it only after the last one unmounts',
    (tester) async {
      final controller = Issue2123Controller();

      Widget buildApp({required bool showFirst}) {
        return MaterialApp(
          home: Column(
            children: [
              if (showFirst)
                GetBuilder<Issue2123Controller>(
                  global: false,
                  init: controller,
                  builder: (controller) => const Text('first'),
                ),
              GetBuilder<Issue2123Controller>(
                global: false,
                init: controller,
                builder: (controller) => const Text('second'),
              ),
            ],
          ),
        );
      }

      await tester.pumpWidget(buildApp(showFirst: true));
      expect(controller.onInitCalls, 1);

      await tester.pumpWidget(buildApp(showFirst: false));
      expect(
        controller.onCloseCalls,
        0,
        reason: 'the second builder still uses the controller',
      );

      await tester.pumpWidget(const SizedBox());
      expect(controller.onCloseCalls, 1);
    },
  );
}
