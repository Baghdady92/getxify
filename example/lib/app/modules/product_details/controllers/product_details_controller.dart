import 'package:getxify/getxify.dart';

/// Controller for the product details screen
/// Manages product details display with route parameters
class ProductDetailsController extends GetxController {
  /// The product ID from route parameters
  final String productId;

  ProductDetailsController(this.productId);

  @override
  void onInit() {
    super.onInit();
    Get.log('ProductDetailsController created with id: $productId');
  }

  @override
  void onClose() {
    Get.log('ProductDetailsController close with id: $productId');
    super.onClose();
  }
}
