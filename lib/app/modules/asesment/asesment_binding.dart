import 'package:get/get.dart';

import 'asesment_controller.dart';

class AsesmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AsesmentController>(
      () => AsesmentController(),
    );
  }
}
