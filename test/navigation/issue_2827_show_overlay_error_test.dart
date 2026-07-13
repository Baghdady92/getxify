// Regression test for upstream issue #2827:
// Get.showOverlay only removed its barrier and loading widget in an
// `on Exception` clause, so a non-Exception throw (a String error, or any
// Error) left the overlay on screen forever.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

import 'utils/wrapper.dart';

void main() {
  testWidgets("overlay is removed when asyncFunction throws a non-Exception", (
    tester,
  ) async {
    await tester.pumpWidget(Wrapper(child: const Text('page')));
    await tester.pumpAndSettle();

    Object? error;
    Get.showOverlay<void>(
      asyncFunction: () => Future<void>.error('boom'),
      loadingWidget: const Text('loading-marker'),
    ).then(
      (_) {},
      onError: (Object e) {
        error = e;
      },
    );
    await tester.pumpAndSettle();

    // The error still propagates to the caller...
    expect(error, 'boom');
    // ...and the barrier/loader must be gone.
    expect(find.text('loading-marker'), findsNothing);
    expect(find.byType(Opacity), findsNothing);
    expect(find.text('page'), findsOneWidget);
  });

  testWidgets("overlay is removed when asyncFunction throws an Error", (
    tester,
  ) async {
    await tester.pumpWidget(Wrapper(child: const Text('page')));
    await tester.pumpAndSettle();

    Object? error;
    Get.showOverlay<void>(
      asyncFunction: () async => throw StateError('bad state'),
      loadingWidget: const Text('loading-marker'),
    ).then(
      (_) {},
      onError: (Object e) {
        error = e;
      },
    );
    await tester.pumpAndSettle();

    expect(error, isA<StateError>());
    expect(find.text('loading-marker'), findsNothing);
  });

  testWidgets("overlay shows while running and result is returned", (
    tester,
  ) async {
    await tester.pumpWidget(Wrapper(child: const Text('page')));
    await tester.pumpAndSettle();

    int? result;
    Get.showOverlay<int>(
      asyncFunction: () async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        return 42;
      },
      loadingWidget: const Text('loading-marker'),
    ).then((value) => result = value);
    await tester.pump();

    expect(find.text('loading-marker'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(result, 42);
    expect(find.text('loading-marker'), findsNothing);
  });
}
