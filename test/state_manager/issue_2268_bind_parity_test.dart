import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

class ParentController with GetLifeCycleMixin {
  int init = 0;
  int close = 0;

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  test('Bind.replace works over an initialized fenix registration', () {
    Bind.lazyPut<ParentController>(ParentController.new, fenix: true);
    final old = Bind.find<ParentController>();

    Bind.replace<ParentController>(ChildController());

    final current = Bind.find<ParentController>();
    expect(current, isA<ChildController>());
    expect(identical(current, old), isFalse);
    expect(old.close, 1);
    expect(current.init, 1);
  });

  test('Bind.replace works over a never-initialized fenix registration', () {
    Bind.lazyPut<ParentController>(ParentController.new, fenix: true);

    Bind.replace<ParentController>(ChildController());

    expect(Bind.find<ParentController>(), isA<ChildController>());
  });

  test('Bind.lazyReplace works over an initialized fenix registration', () {
    Bind.lazyPut<ParentController>(ParentController.new, fenix: true);
    final old = Bind.find<ParentController>();

    Bind.lazyReplace<ParentController>(ChildController.new);

    final current = Bind.find<ParentController>();
    expect(current, isA<ChildController>());
    expect(identical(current, old), isFalse);
    expect(old.close, 1);
  });

  test('Bind.replace still works over a plain put registration', () {
    Bind.put<ParentController>(ParentController());
    final old = Bind.find<ParentController>();

    Bind.replace<ParentController>(ChildController());

    final current = Bind.find<ParentController>();
    expect(current, isA<ChildController>());
    expect(identical(current, old), isFalse);
  });
}
