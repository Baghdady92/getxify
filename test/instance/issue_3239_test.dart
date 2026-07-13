import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

class AsyncController with GetLifeCycleMixin {
  int init = 0;
  int close = 0;
  bool ready = false;

  Future<void> setup() async {
    await Future<void>.delayed(Duration.zero);
    ready = true;
  }

  @override
  void onInit() {
    init++;
    super.onInit();
  }

  @override
  void onClose() {
    close++;
    super.onClose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Get.putAsync registers and initializes the awaited instance', () async {
    final instance = await Get.putAsync<AsyncController>(() async {
      final controller = AsyncController();
      await controller.setup();
      return controller;
    });

    expect(instance.ready, true);
    expect(instance.init, 1);
    expect(Get.isRegistered<AsyncController>(), true);
    expect(identical(Get.find<AsyncController>(), instance), true);

    Get.delete<AsyncController>();
    expect(instance.close, 1);
    Get.reset();
  });

  test('Get.putAsync supports tags', () async {
    final one = await Get.putAsync<AsyncController>(
      () async => AsyncController(),
      tag: 'one',
    );
    final two = await Get.putAsync<AsyncController>(
      () async => AsyncController(),
      tag: 'two',
    );

    expect(identical(one, two), false);
    expect(identical(Get.find<AsyncController>(tag: 'one'), one), true);
    expect(identical(Get.find<AsyncController>(tag: 'two'), two), true);
    Get.reset();
  });

  test('Get.putAsync supports permanent instances', () async {
    final instance = await Get.putAsync<AsyncController>(
      () async => AsyncController(),
      permanent: true,
    );

    Get.delete<AsyncController>();
    expect(Get.isRegistered<AsyncController>(), true);
    expect(instance.close, 0);

    Get.delete<AsyncController>(force: true);
    expect(Get.isRegistered<AsyncController>(), false);
    expect(instance.close, 1);
    Get.reset();
  });
}
