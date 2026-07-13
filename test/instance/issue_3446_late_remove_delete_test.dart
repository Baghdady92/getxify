import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

class LifecycleController extends GetxController {
  int inits = 0;
  int closes = 0;

  @override
  void onInit() {
    inits++;
    super.onInit();
  }

  @override
  void onClose() {
    closes++;
    super.onClose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Regression test for jonataslaw/getx#3446, #3315 and #3351.
  //
  // When a route is popped, its dependencies are marked dirty
  // (`Get.markAsDirty`). If the same route is pushed again before the old
  // route disposes, the binding re-registers the key and the superseded
  // factory is kept in `lateRemove`. When the old route finally disposes,
  // `Get.delete` must dispose ONLY the superseded instance and keep the
  // fresh registration (and its live controller) untouched.
  test(
      'delete disposes only the superseded (lateRemove) instance and '
      'keeps the fresh registration alive', () async {
    Get.lazyPut(LifecycleController.new);
    final first = Get.find<LifecycleController>();
    expect(first.inits, 1);

    // Simulates `reportRouteWillDispose` on pop.
    Get.markAsDirty<LifecycleController>();

    // Simulates the binding of the re-pushed route plus the page
    // resolving the controller again.
    Get.lazyPut(LifecycleController.new);
    final second = Get.find<LifecycleController>();
    expect(identical(first, second), false);
    expect(second.inits, 1);

    // Simulates the old route disposing (`_removeDependencyByRoute`).
    final removed = Get.delete<LifecycleController>();

    expect(removed, false,
        reason: 'the key must stay registered for the new route');
    expect(first.closes, 1);
    expect(second.closes, 0);
    expect(Get.isRegistered<LifecycleController>(), true);
    expect(identical(Get.find<LifecycleController>(), second), true);

    // A later, regular delete (the new route disposing) removes the
    // remaining registration for good.
    final removedAgain = Get.delete<LifecycleController>();
    expect(removedAgain, true);
    expect(second.closes, 1);
    expect(Get.isRegistered<LifecycleController>(), false);

    Get.reset();
  });

  // Same protocol, but with two supersessions in flight (the route was
  // popped and re-pushed twice before any old route disposed). Every
  // pending disposal must peel off the oldest superseded instance; the
  // live controller is only removed by the last delete.
  test('nested lateRemove chain is disposed oldest-first', () async {
    Get.lazyPut(LifecycleController.new);
    final first = Get.find<LifecycleController>();

    Get.markAsDirty<LifecycleController>();
    Get.lazyPut(LifecycleController.new);
    final second = Get.find<LifecycleController>();

    Get.markAsDirty<LifecycleController>();
    Get.lazyPut(LifecycleController.new);
    final third = Get.find<LifecycleController>();

    // First route disposes: only the first instance goes away.
    expect(Get.delete<LifecycleController>(), false);
    expect(first.closes, 1);
    expect(second.closes, 0);
    expect(third.closes, 0);

    // Second route disposes: only the second instance goes away.
    expect(Get.delete<LifecycleController>(), false);
    expect(second.closes, 1);
    expect(third.closes, 0);
    expect(Get.isRegistered<LifecycleController>(), true);
    expect(identical(Get.find<LifecycleController>(), third), true);

    // Third (live) route disposes: the registration is removed.
    expect(Get.delete<LifecycleController>(), true);
    expect(third.closes, 1);
    expect(Get.isRegistered<LifecycleController>(), false);

    Get.reset();
  });

  // Regression test for the fenix part of jonataslaw/getx#3292: a fenix
  // delete keeps the factory for resurrection, so it must also clear the
  // dirty flag. Otherwise a later re-registration of the same key would
  // treat the retained factory as stale, chain it in `lateRemove`, and the
  // resurrected live controller would never receive `onClose`.
  test('fenix delete resets the dirty flag so the factory can be reused',
      () async {
    Get.lazyPut(LifecycleController.new, fenix: true);
    final first = Get.find<LifecycleController>();

    Get.markAsDirty<LifecycleController>();
    Get.delete<LifecycleController>();

    expect(first.closes, 1);
    expect(Get.isRegistered<LifecycleController>(), true);

    // Simulates re-entering the route: the binding registers the key
    // again and the page resolves the controller.
    Get.lazyPut(LifecycleController.new, fenix: true);
    final second = Get.find<LifecycleController>();
    expect(identical(first, second), false);
    expect(second.inits, 1);

    // Popping the route again must close the resurrected instance.
    Get.markAsDirty<LifecycleController>();
    Get.delete<LifecycleController>();

    expect(second.closes, 1);
    expect(Get.isRegistered<LifecycleController>(), true);

    Get.reset();
  });
}
