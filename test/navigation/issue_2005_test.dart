import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

import 'utils/wrapper.dart';

// https://github.com/jonataslaw/getx/issues/2005
// Get.bottomSheet should accept arguments (and a route name) directly,
// like Get.dialog, instead of forcing callers to build RouteSettings.
void main() {
  testWidgets('Get.bottomSheet forwards arguments and name to its route', (
    tester,
  ) async {
    await tester.pumpWidget(Wrapper(child: Container()));
    await tester.pump();

    Object? routeArguments;
    String? routeName;
    Get.bottomSheet(
      Builder(
        builder: (context) {
          final settings = ModalRoute.of(context)!.settings;
          routeArguments = settings.arguments;
          routeName = settings.name;
          return const Text('sheet');
        },
      ),
      arguments: 'sheet arguments',
      name: '/sheet',
    );
    await tester.pumpAndSettle();

    expect(find.text('sheet'), findsOneWidget);
    expect(routeArguments, 'sheet arguments');
    expect(routeName, '/sheet');
    expect(Get.arguments, 'sheet arguments');

    Get.closeBottomSheet();
    await tester.pumpAndSettle();
  });

  testWidgets('an explicit settings wins over the arguments shortcut', (
    tester,
  ) async {
    await tester.pumpWidget(Wrapper(child: Container()));
    await tester.pump();

    Object? routeArguments;
    Get.bottomSheet(
      Builder(
        builder: (context) {
          routeArguments = ModalRoute.of(context)!.settings.arguments;
          return const Text('sheet');
        },
      ),
      arguments: 'ignored',
      settings: const RouteSettings(arguments: 'from settings'),
    );
    await tester.pumpAndSettle();

    expect(routeArguments, 'from settings');

    Get.closeBottomSheet();
    await tester.pumpAndSettle();
  });
}
