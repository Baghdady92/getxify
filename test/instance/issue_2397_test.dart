import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

class ReloadController with GetLifeCycleMixin {
  int init = 0;
  int close = 0;
  int count = 0;

  void increment() => count++;

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

class ReloadService extends GetxService {
  int close = 0;

  @override
  void onClose() {
    close++;
    super.onClose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Get.reloadAll calls onClose before clearing instances', () async {
    Get.lazyPut<ReloadController>(() => ReloadController());
    final first = Get.find<ReloadController>();
    first.increment();
    expect(first.count, 1);
    expect(first.close, 0);

    Get.reloadAll();

    expect(first.close, 1);
    expect(Get.isRegistered<ReloadController>(), true);

    final second = Get.find<ReloadController>();
    expect(identical(second, first), false);
    expect(second.count, 0);
    expect(second.init, 1);
    Get.reset();
  });

  test('Get.reloadAll skips GetxService unless forced', () async {
    final service = Get.put(ReloadService());

    Get.reloadAll();
    expect(service.close, 0);
    expect(identical(Get.find<ReloadService>(), service), true);

    Get.reloadAll(force: true);
    expect(service.close, 1);
    Get.reset();
  });

  test('Get.reloadAll skips permanent instances unless forced', () async {
    final controller = Get.put(ReloadController(), permanent: true);

    Get.reloadAll();
    expect(controller.close, 0);
    expect(identical(Get.find<ReloadController>(), controller), true);

    Get.reloadAll(force: true);
    expect(controller.close, 1);
    Get.reset();
  });
}
