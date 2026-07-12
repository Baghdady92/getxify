// Regression tests for upstream issue #3266:
// The very first route information report after startup must be sent to
// the engine with replace semantics. Reporting it as a push creates a
// phantom browser history entry on plain page load (the Safari/Chrome back
// button lights up on accessing index.html).
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('first'));
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('second'));
  }
}

GetMaterialApp buildApp() {
  return GetMaterialApp(
    initialRoute: '/first',
    getPages: [
      GetPage(name: '/first', page: () => const FirstPage()),
      GetPage(name: '/second', page: () => const SecondPage()),
    ],
  );
}

/// Captures the `routeInformationUpdated` messages the framework sends to
/// the engine (the same messages that drive the browser history on web).
List<Map<dynamic, dynamic>> captureRouteInformationUpdates(
  WidgetTester tester,
) {
  final updates = <Map<dynamic, dynamic>>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.navigation,
    (call) async {
      if (call.method == 'routeInformationUpdated') {
        updates.add(call.arguments as Map<dynamic, dynamic>);
      }
      return null;
    },
  );
  addTearDown(() {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.navigation,
      null,
    );
  });
  return updates;
}

void main() {
  tearDown(Get.reset);

  testWidgets(
    'the initial route report after startup is a history replace, not a push',
    (tester) async {
      final updates = captureRouteInformationUpdates(tester);

      // The engine's default location is '/', so resolving the initial
      // route to '/first' produces a URL update on startup.
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(updates, isNotEmpty);
      expect(updates.first['uri'], '/first');
      expect(updates.first['replace'], isTrue);
    },
  );

  testWidgets('later push navigations are still reported as pushes', (
    tester,
  ) async {
    final updates = captureRouteInformationUpdates(tester);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    updates.clear();

    Get.toNamed('/second');
    await tester.pumpAndSettle();

    expect(updates, isNotEmpty);
    expect(updates.last['uri'], '/second');
    expect(updates.last['replace'], isFalse);
  });
}
