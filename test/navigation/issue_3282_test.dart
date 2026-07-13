// Regression tests for upstream issue #3282:
// GetPage/GetPageRoute must expose PageRoute.allowSnapshotting so route
// transition snapshotting can be disabled per page (e.g. for pages whose
// content keeps animating during transitions).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

BuildContext? capturedContext;

class SnapshotlessPage extends StatelessWidget {
  const SnapshotlessPage({super.key});

  @override
  Widget build(BuildContext context) {
    capturedContext = context;
    return const Scaffold(body: Text('snapshotless'));
  }
}

void main() {
  setUp(() => capturedContext = null);
  tearDown(Get.reset);

  test('GetPage defaults allowSnapshotting to true and copyWith keeps it', () {
    final page = GetPage(name: '/a', page: Container.new);
    expect(page.allowSnapshotting, isTrue);

    final disabled = GetPage(
      name: '/a',
      page: Container.new,
      allowSnapshotting: false,
    );
    expect(disabled.allowSnapshotting, isFalse);
    expect(disabled.copyWith().allowSnapshotting, isFalse);
    expect(
      disabled.copyWith(allowSnapshotting: true).allowSnapshotting,
      isTrue,
    );
  });

  test('GetPageRoute honors an explicit allowSnapshotting argument', () {
    expect(GetPageRoute(page: Container.new).allowSnapshotting, isTrue);
    expect(
      GetPageRoute(page: Container.new, allowSnapshotting: false)
          .allowSnapshotting,
      isFalse,
    );
  });

  testWidgets('GetPage.allowSnapshotting reaches the created route', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/snapshotless',
        getPages: [
          GetPage(
            name: '/snapshotless',
            page: () => const SnapshotlessPage(),
            allowSnapshotting: false,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final route = ModalRoute.of(capturedContext!)! as PageRoute;
    expect(route, isA<GetPageRoute>());
    expect(route.allowSnapshotting, isFalse);
  });
}
