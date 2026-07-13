import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

class AsyncInitController extends GetxController {
  AsyncInitController(this.value);

  final int value;
  int init = 0;

  @override
  void onInit() {
    init++;
    super.onInit();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  test('Bind.putAsync awaits the builder and registers the instance', () async {
    final bind = await Bind.putAsync<AsyncInitController>(() async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return AsyncInitController(42);
    });

    expect(bind, isA<Bind<AsyncInitController>>());
    expect(Get.isRegistered<AsyncInitController>(), isTrue);

    final controller = Bind.find<AsyncInitController>();
    expect(controller.value, 42);
    expect(controller.init, 1);
  });

  test('Bind.putAsync honors tags', () async {
    await Bind.putAsync<AsyncInitController>(
      () async => AsyncInitController(1),
      tag: 'a',
    );
    await Bind.putAsync<AsyncInitController>(
      () async => AsyncInitController(2),
      tag: 'b',
    );

    expect(Bind.find<AsyncInitController>(tag: 'a').value, 1);
    expect(Bind.find<AsyncInitController>(tag: 'b').value, 2);
  });
}
