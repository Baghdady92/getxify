import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

// Regression tests for https://github.com/jonataslaw/getx/issues/2183:
// deep-linking to a nested route (web URL / initial route) ran the parent
// pages' bindings on the leaf route, so the parents' controllers were
// linked to the leaf. Navigating back to a parent page then disposed the
// controller the still-visible parent view depends on
// ("ProductsController" not found).

class ProductsController extends GetxController {
  static int created = 0;
  static int closed = 0;

  final products = <String>['p-42'].obs;

  ProductsController() {
    created++;
  }

  @override
  void onClose() {
    closed++;
    super.onClose();
  }
}

class ProductDetailsController extends GetxController {
  ProductDetailsController(this.productId);

  final String productId;
  late final String product;

  @override
  void onInit() {
    super.onInit();
    // Looks the product up from the parent page's controller: the FIRST
    // find of ProductsController happens here, while the details route is
    // building.
    product = Get.find<ProductsController>().products.firstWhere(
      (p) => p == 'p-$productId',
      orElse: () => 'missing-$productId',
    );
  }
}

class ProductsBinding extends BindingsInterface<void> {
  @override
  void dependencies() {
    Get.lazyPut(() => ProductsController());
  }
}

class ProductDetailsBinding extends BindingsInterface<void> {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ProductDetailsController(Get.parameters['productId'] ?? '?'),
    );
  }
}

class RootView extends StatelessWidget {
  const RootView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetRouterOutlet(anchorRoute: '/', initialRoute: '/home'),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetRouterOutlet(
        anchorRoute: '/home',
        initialRoute: '/home/products',
      ),
    );
  }
}

/// Uses its controller lazily (only on user interaction), like a list page
/// whose handlers call `Get.find` — it does not `find` during build.
class ProductsView extends StatelessWidget {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('products-view'),
        TextButton(
          onPressed: () => Get.find<ProductsController>().products.add('new'),
          child: const Text('add-product'),
        ),
      ],
    );
  }
}

/// Same page, but finding the controller during build (GetView-style).
class EagerProductsView extends GetView<ProductsController> {
  const EagerProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Text('products-count-${controller.products.length}'));
  }
}

class ProductDetailsView extends GetView<ProductDetailsController> {
  const ProductDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Text('details-${controller.product}');
  }
}

GetMaterialApp buildApp({required Widget Function() productsPage}) {
  return GetMaterialApp(
    initialRoute: '/home/products/42',
    getPages: [
      GetPage(
        name: '/',
        page: () => const RootView(),
        participatesInRootNavigator: true,
        children: [
          GetPage(
            name: '/home',
            page: () => const HomeView(),
            children: [
              GetPage(
                name: '/products',
                page: productsPage,
                binding: ProductsBinding(),
                children: [
                  GetPage(
                    name: '/:productId',
                    page: () => const ProductDetailsView(),
                    binding: ProductDetailsBinding(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

void main() {
  setUp(() {
    ProductsController.created = 0;
    ProductsController.closed = 0;
  });
  tearDown(Get.reset);

  testWidgets(
    'parent controller survives leaving a deep-linked child route '
    '(controller found first under the child route)',
    (tester) async {
      await tester.pumpWidget(
        buildApp(productsPage: () => const ProductsView()),
      );
      await tester.pumpAndSettle();

      // The deep link landed on the details page and the parent binding ran.
      expect(find.text('details-p-42'), findsOneWidget);
      expect(Get.isRegistered<ProductsController>(), isTrue);
      expect(ProductsController.created, 1);

      // Equivalent of tapping the "products" tab in the repro app.
      Get.toNamed('/home/products');
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('products-view'), findsOneWidget);

      // The parent page is visible: its controller must not have been
      // disposed with the details route.
      expect(Get.isRegistered<ProductsController>(), isTrue);
      expect(ProductsController.closed, 0);

      // The view can still use it (upstream repro threw
      // InstanceNotFoundException here).
      await tester.tap(find.text('add-product'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(ProductsController.created, 1);
    },
  );

  testWidgets(
    'parent controller survives leaving a deep-linked child route '
    '(controller found during the parent view build)',
    (tester) async {
      await tester.pumpWidget(
        buildApp(productsPage: () => const EagerProductsView()),
      );
      await tester.pumpAndSettle();

      expect(find.text('details-p-42'), findsOneWidget);
      expect(Get.isRegistered<ProductsController>(), isTrue);

      Get.toNamed('/home/products');
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('products-count-1'), findsOneWidget);
      expect(Get.isRegistered<ProductsController>(), isTrue);
      expect(ProductsController.closed, 0);
      expect(ProductsController.created, 1);
    },
  );

  testWidgets('deep-linked child route still disposes its own controller', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp(productsPage: () => const ProductsView()));
    await tester.pumpAndSettle();

    expect(Get.isRegistered<ProductDetailsController>(), isTrue);

    Get.toNamed('/home/products');
    await tester.pumpAndSettle();

    // The child's own controller still dies with the child route.
    expect(Get.isRegistered<ProductDetailsController>(), isFalse);
  });

  group('ParseRouteTree.bindingOwnersOf', () {
    test('attributes each binding of a branch to the page that declared it', () {
      final rootBinding = ProductsBinding();
      final rootListedBinding = ProductsBinding();
      final childBinding = ProductsBinding();
      final leafBinding = ProductDetailsBinding();

      final tree = ParseRouteTree(routes: <GetPage>[]);
      tree.addRoute(
        GetPage(
          name: '/a',
          page: () => const ProductsView(),
          binding: rootBinding,
          bindings: [rootListedBinding],
          children: [
            GetPage(
              name: '/b',
              page: () => const ProductsView(),
              binding: childBinding,
              children: [
                GetPage(
                  name: '/c',
                  page: () => const ProductsView(),
                  bindings: [leafBinding],
                ),
              ],
            ),
          ],
        ),
      );

      final branch = tree.matchRoute('/a/b/c').currentTreeBranch;
      final owners = ParseRouteTree.bindingOwnersOf(branch);

      // The root page's `binding:` field is folded into descendants'
      // merged lists and must be attributed to the root.
      expect(owners[rootBinding], '/a');
      expect(owners[rootListedBinding], '/a');
      expect(owners[childBinding], '/a/b');
      expect(owners[leafBinding], '/a/b/c');
    });

    test('returns an empty map for an empty branch', () {
      expect(ParseRouteTree.bindingOwnersOf(const <GetPage>[]), isEmpty);
    });
  });
}
