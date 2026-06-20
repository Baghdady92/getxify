import 'package:getxify/getxify.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Binding {
  @override
  List<Bind> dependencies() {
    return [Bind.lazyPut<HomeController>(() => HomeController())];
  }
}
