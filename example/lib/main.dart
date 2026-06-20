import 'package:flutter/material.dart';
import 'package:getxify/getxify.dart';

import './services/auth_service.dart';
import 'app/routes/app_pages.dart';

void main() {
  runApp(
    GetMaterialApp(
      title: "GetXify Example App",
      binds: [Bind.put(AuthService())],
      getPages: AppPages.routes,
      initialRoute: AppPages.initial,
    ),
  );
}
