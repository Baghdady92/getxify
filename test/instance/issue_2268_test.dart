import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

class ParentController with GetLifeCycleMixin {
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

class ChildController extends ParentController {}

class ParentService extends GetxService {
  int close = 0;

  @override
  void onClose() {
    close++;
    super.onClose();
  }
}

class ChildService extends ParentService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Get.replace works over an initialized fenix registration', () async {
    Get.lazyPut<ParentController>(() => ParentController(), fenix: true);
    final old = Get.find<ParentController>();

    Get.replace<ParentController>(ChildController());

    final current = Get.find<ParentController>();
    expect(current, isA<ChildController>());
    expect(identical(current, old), false);
    expect(old.close, 1);
    expect(current.init, 1);
    Get.reset();
  });

  test('Get.replace works over a never-initialized fenix registration',
      () async {
    Get.lazyPut<ParentController>(() => ParentController(), fenix: true);

    Get.replace<ParentController>(ChildController());

    expect(Get.find<ParentController>(), isA<ChildController>());
    Get.reset();
  });

  test('Get.lazyReplace works over a fenix registration and the new builder '
      'resurrects', () async {
    Get.lazyPut<ParentController>(() => ParentController(), fenix: true);
    final old = Get.find<ParentController>();

    Get.lazyReplace<ParentController>(() => ChildController(), fenix: true);

    final current = Get.find<ParentController>();
    expect(current, isA<ChildController>());
    expect(old.close, 1);
    current.increment();
    expect(Get.find<ParentController>().count, 1);

    Get.delete<ParentController>();
    final resurrected = Get.find<ParentController>();
    expect(resurrected, isA<ChildController>());
    expect(identical(resurrected, current), false);
    expect(resurrected.count, 0);
    Get.reset();
  });

  test('Get.replace works while a lateRemove chain is pending', () async {
    final first = Get.put<ParentController>(ParentController());
    Get.markAsDirty<ParentController>();
    final second = Get.put<ParentController>(ParentController());
    expect(identical(first, second), false);

    final replacement = ChildController();
    Get.replace<ParentController>(replacement);

    expect(first.close, 1);
    expect(second.close, 1);
    expect(identical(Get.find<ParentController>(), replacement), true);
    Get.reset();
  });

  test('Get.replace disposes and replaces a GetxService', () async {
    final old = Get.put(ParentService());

    Get.replace<ParentService>(ChildService());

    expect(old.close, 1);
    expect(Get.find<ParentService>(), isA<ChildService>());
    Get.reset();
  });
}
