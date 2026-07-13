import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

class TaggedController extends GetxController {
  int counter = 0;
}

void main() {
  testWidgets(
    'GetBuilder without the registration tag throws a descriptive BindError',
    (tester) async {
      Get.put(TaggedController(), tag: 'my-tag');
      addTearDown(
        () => Get.delete<TaggedController>(tag: 'my-tag', force: true),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: GetBuilder<TaggedController>(
            builder: (controller) => Text('${controller.counter}'),
          ),
        ),
      );

      final exception = tester.takeException();
      expect(exception, isA<BindError>());
      final description = exception.toString();
      expect(description, contains('TaggedController'));
      expect(description, contains('without a tag'));
      expect(description, contains('init'));
      expect(description, contains('Get.put'));
    },
  );

  testWidgets(
    'GetBuilder with an unregistered tag names the tag in the error',
    (tester) async {
      Get.put(TaggedController());
      addTearDown(() => Get.delete<TaggedController>(force: true));

      await tester.pumpWidget(
        MaterialApp(
          home: GetBuilder<TaggedController>(
            tag: 'missing',
            builder: (controller) => Text('${controller.counter}'),
          ),
        ),
      );

      final exception = tester.takeException();
      expect(exception, isA<BindError>());
      expect(exception.toString(), contains('with tag "missing"'));
    },
  );

  testWidgets('GetBuilder with the matching tag keeps working', (tester) async {
    Get.put(TaggedController(), tag: 'my-tag');
    addTearDown(() => Get.delete<TaggedController>(tag: 'my-tag', force: true));

    await tester.pumpWidget(
      MaterialApp(
        home: GetBuilder<TaggedController>(
          tag: 'my-tag',
          builder: (controller) => Text('${controller.counter}'),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('GetBuilder with init and no registration keeps working', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: GetBuilder<TaggedController>(
          init: TaggedController(),
          builder: (controller) => Text('${controller.counter}'),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('0'), findsOneWidget);
  });
}
