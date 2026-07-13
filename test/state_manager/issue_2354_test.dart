import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

class Issue2354Controller extends GetxController {
  int counter = 0;

  void increment() {
    counter++;
    update();
  }
}

void main() {
  testWidgets(
    'GetBuilder initState callback can access state.controller when '
    'the controller comes from init',
    (tester) async {
      Issue2354Controller? captured;

      await tester.pumpWidget(
        MaterialApp(
          home: GetBuilder<Issue2354Controller>(
            init: Issue2354Controller(),
            initState: (state) {
              captured = state.controller;
            },
            builder: (controller) => Text('counter: ${controller.counter}'),
          ),
        ),
      );

      expect(captured, isNotNull);
      expect(captured, same(Get.find<Issue2354Controller>()));
      expect(find.text('counter: 0'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'GetBuilder initState callback can access state.controller when '
    'the controller is pre-registered',
    (tester) async {
      final registered = Get.put(Issue2354Controller());
      Issue2354Controller? captured;

      await tester.pumpWidget(
        MaterialApp(
          home: GetBuilder<Issue2354Controller>(
            initState: (state) {
              captured = state.controller;
            },
            builder: (controller) => Text('counter: ${controller.counter}'),
          ),
        ),
      );

      expect(captured, same(registered));

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'GetBuilder initState callback can mutate the controller before '
    'the first build',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GetBuilder<Issue2354Controller>(
            init: Issue2354Controller(),
            initState: (state) => state.controller.counter = 42,
            builder: (controller) => Text('counter: ${controller.counter}'),
          ),
        ),
      );

      expect(find.text('counter: 42'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    },
  );
}
