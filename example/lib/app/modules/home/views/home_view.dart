import 'package:flutter/material.dart';
import 'package:getxify/getxify.dart';

import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';

/// Home screen view
/// Demonstrates nested routing with bottom navigation
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(color: Colors.yellow, width: double.infinity, height: 25),
        Expanded(
          child: GetRouterOutlet.builder(
            route: Routes.home,
            builder: (context) {
              return Scaffold(
                body: GetRouterOutlet(
                  initialRoute: Routes.dashboard,
                  anchorRoute: Routes.home,
                ),
                bottomNavigationBar: IndexedRouteBuilder(
                  routes: const [
                    Routes.dashboard,
                    Routes.profile,
                    Routes.products,
                  ],
                  builder: (context, routes, index) {
                    final delegate = context.delegate;
                    return BottomNavigationBar(
                      currentIndex: index,
                      onTap: (value) => delegate.toNamed(routes[value]),
                      items: const [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.home),
                          label: 'Home',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.account_box_rounded),
                          label: 'Profile',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.shopping_cart),
                          label: 'Products',
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
