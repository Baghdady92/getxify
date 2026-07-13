import 'package:flutter/material.dart';
import 'package:getxify/getxify.dart';

import '../controllers/product_details_controller.dart';

/// Product details screen view
/// Demonstrates navigation with route parameters
class ProductDetailsView extends GetView<ProductDetailsController> {
  const ProductDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'ProductDetailsView is working',
              style: TextStyle(fontSize: 20),
            ),
            Text('ProductId: ${controller.productId}'),
          ],
        ),
      ),
    );
  }
}
