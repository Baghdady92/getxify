import 'package:example/app/modules/products/controllers/products_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductsController', () {
    late ProductsController controller;

    setUp(() {
      controller = ProductsController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('initially has empty products list', () {
      expect(controller.products.value, isEmpty);
    });

    test('loadDemoProducts adds a product', () {
      controller.loadDemoProducts();
      expect(controller.products.length, 1);
      expect(controller.products.first.name, contains('Product added on:'));
    });
  });
}
