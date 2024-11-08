import 'package:get/get.dart';

import 'andon_history_controller.dart';

class AndonHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AndonHistoryController>(
      () => AndonHistoryController(),
    );
  }
}
