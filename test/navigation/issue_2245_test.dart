// Regression tests for upstream issue #2245:
// Get.to with a constructor tear-off (e.g. `Get.to(MyPage.new)`) must
// generate a clean route name like '/MyPage' instead of leaking the
// tear-off's parameter list into the route name/URL.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

class TearOffPage extends StatelessWidget {
  const TearOffPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('tearoff'));
  }
}

void main() {
  tearDown(Get.reset);

  testWidgets('Get.to with a constructor tear-off produces a clean name', (
    tester,
  ) async {
    await tester.pumpWidget(
      const GetMaterialApp(home: Scaffold(body: Text('home'))),
    );
    await tester.pumpAndSettle();

    Get.to(TearOffPage.new);
    await tester.pumpAndSettle();

    expect(find.text('tearoff'), findsOneWidget);
    expect(Get.currentRoute, '/TearOffPage');
  });

  testWidgets('Get.off with a constructor tear-off produces a clean name', (
    tester,
  ) async {
    await tester.pumpWidget(
      const GetMaterialApp(home: Scaffold(body: Text('home'))),
    );
    await tester.pumpAndSettle();

    Get.off(TearOffPage.new);
    await tester.pumpAndSettle();

    expect(find.text('tearoff'), findsOneWidget);
    expect(Get.currentRoute, '/TearOffPage');
  });

  testWidgets('Get.to with a closure keeps its historical name', (
    tester,
  ) async {
    await tester.pumpWidget(
      const GetMaterialApp(home: Scaffold(body: Text('home'))),
    );
    await tester.pumpAndSettle();

    Get.to(() => const TearOffPage());
    await tester.pumpAndSettle();

    expect(find.text('tearoff'), findsOneWidget);
    expect(Get.currentRoute, '/TearOffPage');
  });
}
