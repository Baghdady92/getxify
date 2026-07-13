import 'package:getxify/getxify.dart';

import '../../../../models/demo_product.dart';

/// Controller for the products screen
/// Manages product list and loading operations
class ProductsController extends GetxController {
  /// Observable list of products
  final products = <DemoProduct>[].obs;

  /// Load demo products
  /// In a real app, this would fetch data from an API
  void loadDemoProducts() {
    products.add(
      DemoProduct(
        name: 'Product added on: ${DateTime.now().toString()}',
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      ),
    );
  }

  @override
  void onReady() {
    super.onReady();
    loadDemoProducts();
  }

  @override
  void onClose() {
    Get.printInfo(info: 'Products: onClose');
    super.onClose();
  }
}
