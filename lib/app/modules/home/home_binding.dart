import 'package:get/get.dart';

import 'home_controller.dart';
import '../andon_home/andon_home_controller.dart';
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    Get.lazyPut<AndonHomeController>(() => AndonHomeController());
  }
}
