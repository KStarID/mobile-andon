import 'package:get/get.dart';

import 'update_ases_controller.dart';

class UpdateAsesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UpdateAsesController>(
      () => UpdateAsesController(),
    );
  }
}
