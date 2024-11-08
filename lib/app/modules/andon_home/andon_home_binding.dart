import 'package:get/get.dart';
import '../home/home_controller.dart';
import 'andon_home_controller.dart';

class AndonHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AndonHomeController>(() => AndonHomeController());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
