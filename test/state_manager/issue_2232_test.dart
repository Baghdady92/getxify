import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

class NamedController extends GetxController {
  NamedController(this.name);

  String name;
  bool closed = false;

  @override
  void onClose() {
    closed = true;
    super.onClose();
  }
}

void main() {
  testWidgets('GetBuilder rebinds to the controller of the new tag', (
    tester,
  ) async {
    final first = Get.put(NamedController('first'), tag: 'first');
    final second = Get.put(NamedController('second'), tag: 'second');
    addTearDown(() {
      Get.delete<NamedController>(tag: 'first', force: true);
      Get.delete<NamedController>(tag: 'second', force: true);
    });

    var tag = 'first';
    late StateSetter setTag;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            setTag = setState;
            return GetBuilder<NamedController>(
              tag: tag,
              builder: (controller) => Text(controller.name),
            );
          },
        ),
      ),
    );

    expect(find.text('first'), findsOneWidget);

    setTag(() => tag = 'second');
    await tester.pump();

    expect(find.text('second'), findsOneWidget);
    expect(find.text('first'), findsNothing);

    // The rebound element listens to the new tag's controller.
    second.name = 'second-updated';
    second.update();
    await tester.pump();
    expect(find.text('second-updated'), findsOneWidget);

    // It no longer rebuilds for the old tag's controller.
    first.name = 'first-updated';
    first.update();
    await tester.pump();
    expect(find.text('first-updated'), findsNothing);
    expect(find.text('second-updated'), findsOneWidget);

    // Externally registered controllers are not disposed by the rebind.
    expect(Get.isRegistered<NamedController>(tag: 'first'), isTrue);
    expect(first.closed, isFalse);
  });

  testWidgets(
    'changing tag disposes an auto-removed controller created under the '
    'old tag and creates one for the new tag',
    (tester) async {
      addTearDown(() {
        Get.delete<NamedController>(tag: 'a', force: true);
        Get.delete<NamedController>(tag: 'b', force: true);
      });

      var tag = 'a';
      late StateSetter setTag;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              setTag = setState;
              return GetBuilder<NamedController>(
                tag: tag,
                init: NamedController(tag),
                builder: (controller) => Text(controller.name),
              );
            },
          ),
        ),
      );

      expect(find.text('a'), findsOneWidget);
      final firstInstance = Get.find<NamedController>(tag: 'a');

      setTag(() => tag = 'b');
      await tester.pump();

      expect(find.text('b'), findsOneWidget);
      expect(Get.isRegistered<NamedController>(tag: 'a'), isFalse);
      expect(firstInstance.closed, isTrue);
      expect(Get.isRegistered<NamedController>(tag: 'b'), isTrue);
    },
  );

  testWidgets('rebuild with an unchanged tag keeps the same controller', (
    tester,
  ) async {
    final controller = Get.put(NamedController('stable'), tag: 'stable');
    addTearDown(() => Get.delete<NamedController>(tag: 'stable', force: true));

    late StateSetter rebuild;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return GetBuilder<NamedController>(
              tag: 'stable',
              builder: (c) => Text('${identical(c, controller)}'),
            );
          },
        ),
      ),
    );

    expect(find.text('true'), findsOneWidget);

    rebuild(() {});
    await tester.pump();

    expect(find.text('true'), findsOneWidget);
    expect(controller.closed, isFalse);
    expect(Get.isRegistered<NamedController>(tag: 'stable'), isTrue);
  });
}
