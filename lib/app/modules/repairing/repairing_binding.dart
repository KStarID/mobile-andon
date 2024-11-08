import 'package:get/get.dart';

import '../home/home_controller.dart';
import 'repairing_controller.dart';

class RepairingBinding extends Bindings {
  @override
  void dependencies() {
    // Pastikan HomeController diinisialisasi terlebih dahulu
    Get.put(HomeController());
    Get.lazyPut<RepairingController>(() => RepairingController());
  }
}
