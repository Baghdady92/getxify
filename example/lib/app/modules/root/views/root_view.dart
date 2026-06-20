import 'package:flutter/material.dart';
import 'package:getxify/getxify.dart';

import '../../../routes/app_pages.dart';
import '../controllers/root_controller.dart';
import 'drawer.dart';

/// Root navigator view
/// Manages the top-level navigation with drawer and router outlet
class RootView extends GetView<RootController> {
  const RootView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerWidget(),
      appBar: AppBar(
        title: RouterListener(
          builder: (context) {
            final title = context.location;
            return Text(title);
          },
        ),
        centerTitle: true,
      ),
      body: GetRouterOutlet(initialRoute: Routes.home, anchorRoute: '/'),
    );
  }
}
