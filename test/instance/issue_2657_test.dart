import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

class KeyController with GetLifeCycleMixin {
  int init = 0;

  @override
  void onInit() {
    init++;
    super.onInit();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('registration with an explicit nullable generic shares the '
      'non-nullable key', () async {
    final instance = Get.put<KeyController?>(KeyController());

    expect(Get.isRegistered<KeyController>(), true);
    expect(identical(Get.find<KeyController>(), instance), true);
    expect(identical(Get.find<KeyController?>(), instance), true);
    expect(instance!.init, 1);

    Get.delete<KeyController>();
    expect(Get.isRegistered<KeyController>(), false);
    expect(Get.isRegistered<KeyController?>(), false);
    Get.reset();
  });

  test('registration inferred from a nullable context shares the '
      'non-nullable key', () async {
    // The nullable context type can make Dart infer S as `KeyController?`,
    // which previously registered under the divergent key "KeyController?".
    KeyController? instance = Get.put(KeyController());

    expect(Get.isRegistered<KeyController>(), true);
    expect(identical(Get.find<KeyController>(), instance), true);
    Get.reset();
  });

  test('lazyPut with a nullable generic is found with the non-nullable '
      'type', () async {
    Get.lazyPut<KeyController?>(() => KeyController());

    expect(Get.isRegistered<KeyController>(), true);
    final instance = Get.find<KeyController>();
    expect(instance.init, 1);
    Get.reset();
  });
}
