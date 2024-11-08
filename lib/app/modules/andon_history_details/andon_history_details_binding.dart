import 'package:get/get.dart';

import 'andon_history_details_controller.dart';

class AndonHistoryDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AndonHistoryDetailsController>(
      () => AndonHistoryDetailsController(),
    );
  }
}
