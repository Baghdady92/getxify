import 'package:flutter/material.dart';
import 'package:getxify/getxify.dart';

import '../../../routes/app_pages.dart';
import '../controllers/products_controller.dart';

/// Products screen view
/// Demonstrates list management and navigation with parameters
class ProductsView extends GetView<ProductsController> {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.loadDemoProductsFromSomeWhere(),
        label: const Text('Add'),
      ),
      body: Column(
        children: [
          const Hero(tag: 'heroLogo', child: FlutterLogo()),
          Expanded(
            child: Obx(
              () => RefreshIndicator(
                onRefresh: () async {
                  controller.products.clear();
                  controller.loadDemoProductsFromSomeWhere();
                },
                child: ListView.builder(
                  itemCount: controller.products.length,
                  itemBuilder: (context, index) {
                    final item = controller.products[index];
                    return ListTile(
                      onTap: () {
                        Get.toNamed(Routes.PRODUCT_DETAILS(item.id));
                      },
                      title: Text(item.name),
                      subtitle: Text(item.id),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
