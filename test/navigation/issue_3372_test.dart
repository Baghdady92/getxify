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

class ThirdPage extends StatelessWidget {
  const ThirdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('third'));
  }
}

GetMaterialApp buildApp() {
  return GetMaterialApp(
    initialRoute: '/first',
    getPages: [
      GetPage(name: '/first', page: () => const FirstPage()),
      GetPage(name: '/second', page: () => const SecondPage()),
      GetPage(name: '/third', page: () => const ThirdPage()),
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

/// Simulates the platform (browser back/forward button or a deep link)
/// reporting a new route to the app.
Future<void> simulatePlatformRoute(WidgetTester tester, String location) async {
  final message = const JSONMethodCodec().encodeMethodCall(
    MethodCall('pushRouteInformation', <String, dynamic>{
      'location': location,
      'state': null,
    }),
  );
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    'flutter/navigation',
    message,
    (_) {},
  );
}

void main() {
  tearDown(Get.reset);

  testWidgets('toNamed is reported to the engine as a history push', (
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

  testWidgets('offAllNamed is reported to the engine as a history replace', (
    tester,
  ) async {
    final updates = captureRouteInformationUpdates(tester);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    Get.toNamed('/second');
    await tester.pumpAndSettle();
    updates.clear();

    Get.offAllNamed('/third');
    await tester.pumpAndSettle();

    expect(updates, isNotEmpty);
    expect(updates.last['uri'], '/third');
    expect(updates.last['replace'], isTrue);
  });

  testWidgets('offNamed is reported to the engine as a history replace', (
    tester,
  ) async {
    final updates = captureRouteInformationUpdates(tester);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    updates.clear();

    Get.offNamed('/second');
    await tester.pumpAndSettle();

    expect(updates, isNotEmpty);
    expect(updates.last['uri'], '/second');
    expect(updates.last['replace'], isTrue);
  });

  testWidgets('off is reported to the engine as a history replace', (
    tester,
  ) async {
    final updates = captureRouteInformationUpdates(tester);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    updates.clear();

    Get.off(() => const SecondPage());
    await tester.pumpAndSettle();

    expect(updates, isNotEmpty);
    expect(updates.last['replace'], isTrue);
  });

  testWidgets(
    'platform back to an existing entry pops the stack instead of duplicating it',
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      Get.toNamed('/second');
      await tester.pumpAndSettle();

      final delegate = Get.rootController.rootDelegate;
      expect(delegate.activePages.length, 2);

      await simulatePlatformRoute(tester, '/first');
      await tester.pumpAndSettle();

      expect(find.text('first'), findsOneWidget);
      expect(delegate.activePages.length, 1);
      expect(delegate.activePages.last.pageSettings?.name, '/first');
    },
  );

  testWidgets(
    'platform back over multiple entries pops back to the matching entry',
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      Get.toNamed('/second');
      await tester.pumpAndSettle();
      Get.toNamed('/third');
      await tester.pumpAndSettle();

      final delegate = Get.rootController.rootDelegate;
      expect(delegate.activePages.length, 3);

      await simulatePlatformRoute(tester, '/first');
      await tester.pumpAndSettle();

      expect(find.text('first'), findsOneWidget);
      expect(delegate.activePages.length, 1);
    },
  );

  testWidgets('a reported route that is not on the stack is still pushed', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await simulatePlatformRoute(tester, '/second');
    await tester.pumpAndSettle();

    expect(find.text('second'), findsOneWidget);

    final delegate = Get.rootController.rootDelegate;
    expect(delegate.activePages.length, 2);
    expect(delegate.activePages.last.pageSettings?.name, '/second');
  });
}
