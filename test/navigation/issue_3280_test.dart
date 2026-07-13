import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

import 'utils/wrapper.dart';

void main() {
  testWidgets(
    "Pushing multiple routes in one frame links controllers to their own route",
    (tester) async {
      await tester.pumpWidget(Wrapper(child: Container()));

      expect(Get.isRegistered<FirstController>(), false);
      expect(Get.isRegistered<SecondController>(), false);

      // Push both routes back-to-back within the same frame.
      Get.to(() => const First());
      Get.to(() => const Second());

      await tester.pumpAndSettle();

      expect(find.byType(Second), findsOneWidget);
      expect(Get.isRegistered<FirstController>(), true);
      expect(Get.isRegistered<SecondController>(), true);

      Get.back();

      await tester.pumpAndSettle();

      expect(find.byType(First), findsOneWidget);
      expect(Get.isRegistered<SecondController>(), false);
      expect(Get.isRegistered<FirstController>(), true);

      Get.back();

      await tester.pumpAndSettle();

      expect(Get.isRegistered<FirstController>(), false);
      expect(Get.isRegistered<SecondController>(), false);
    },
  );
}

class FirstController extends GetxController {}

class SecondController extends GetxController {}

class First extends StatelessWidget {
  const First({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(FirstController());
    return const Center(child: Text("first"));
  }
}

class Second extends StatelessWidget {
  const Second({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SecondController());
    return const Center(child: Text("second"));
  }
}
