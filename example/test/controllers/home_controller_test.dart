import 'package:example/app/modules/home/controllers/home_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeController', () {
    late HomeController controller;

    setUp(() {
      controller = HomeController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('initially has index 0', () {
      expect(controller.currentIndex.value, 0);
    });

    test('changeTab updates index', () {
      controller.changeTab(1);
      expect(controller.currentIndex.value, 1);
    });
  });
}
