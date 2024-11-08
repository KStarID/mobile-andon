import 'package:get/get.dart';

import 'reviewing_controller.dart';

class ReviewingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReviewingController>(
      () => ReviewingController(),
    );
  }
}
