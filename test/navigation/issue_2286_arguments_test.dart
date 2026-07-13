// Regression test for upstream issue #2286: when several pages are pushed
// within the same action (same frame), each page must observe its own
// arguments and parameters while it builds, instead of the arguments of
// whatever route ended up on top of the stack.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

import 'utils/wrapper.dart';

class ArgsRecorder extends StatelessWidget {
  const ArgsRecorder({super.key, required this.tag, required this.seen});

  final String tag;
  final Map<String, Object?> seen;

  @override
  Widget build(BuildContext context) {
    seen[tag] = Get.arguments;
    return Text('page-$tag');
  }
}

class ParamsRecorder extends StatelessWidget {
  const ParamsRecorder({super.key, required this.tag, required this.seen});

  final String tag;
  final Map<String, String?> seen;

  @override
  Widget build(BuildContext context) {
    seen[tag] = Get.parameters['who'];
    return Text('page-$tag');
  }
}

void main() {
  testWidgets('pages pushed in one action each build with their own arguments', (
    tester,
  ) async {
    final seen = <String, Object?>{};

    await tester.pumpWidget(
      Wrapper(
        initialRoute: '/home',
        namedRoutes: [
          GetPage(name: '/home', page: () => const Text('home')),
          GetPage(name: '/a', page: () => ArgsRecorder(tag: 'a', seen: seen)),
          GetPage(name: '/b', page: () => ArgsRecorder(tag: 'b', seen: seen)),
        ],
      ),
    );
    await tester.pumpAndSettle();

    // Two pushes in the same frame; '/a' builds while '/b' is already the
    // top of the stack.
    Get.toNamed('/a', arguments: 'a-args');
    Get.toNamed('/b', arguments: 'b-args');
    await tester.pumpAndSettle();

    expect(seen['a'], 'a-args');
    expect(seen['b'], 'b-args');

    // Outside of a page build the accessor keeps its top-of-stack behavior.
    expect(Get.arguments, 'b-args');
  });

  testWidgets('pages pushed in one action each build with their own parameters', (
    tester,
  ) async {
    final seen = <String, String?>{};

    await tester.pumpWidget(
      Wrapper(
        initialRoute: '/home',
        namedRoutes: [
          GetPage(name: '/home', page: () => const Text('home')),
          GetPage(name: '/a', page: () => ParamsRecorder(tag: 'a', seen: seen)),
          GetPage(name: '/b', page: () => ParamsRecorder(tag: 'b', seen: seen)),
        ],
      ),
    );
    await tester.pumpAndSettle();

    Get.toNamed('/a', parameters: {'who': 'alice'});
    Get.toNamed('/b', parameters: {'who': 'bob'});
    await tester.pumpAndSettle();

    expect(seen['a'], 'alice');
    expect(seen['b'], 'bob');
    expect(Get.parameters['who'], 'bob');
  });

  testWidgets('a single navigation still exposes its arguments globally', (
    tester,
  ) async {
    final seen = <String, Object?>{};

    await tester.pumpWidget(
      Wrapper(
        initialRoute: '/home',
        namedRoutes: [
          GetPage(name: '/home', page: () => const Text('home')),
          GetPage(name: '/a', page: () => ArgsRecorder(tag: 'a', seen: seen)),
        ],
      ),
    );
    await tester.pumpAndSettle();

    Get.toNamed('/a', arguments: {'answer': 42});
    await tester.pumpAndSettle();

    expect(seen['a'], {'answer': 42});
    expect(Get.arguments, {'answer': 42});
  });
}
