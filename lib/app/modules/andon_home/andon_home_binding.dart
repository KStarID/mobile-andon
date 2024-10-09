import 'package:get/get.dart';

import 'andon_home_controller.dart';

class AndonHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AndonHomeController>(
      () => AndonHomeController(),
    );
  }
}
