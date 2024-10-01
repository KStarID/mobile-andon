import 'package:get/get.dart';

import 'add_ases_controller.dart';

class AddAsesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddAsesController>(
      () => AddAsesController(),
    );
  }
}
