import 'package:get/get.dart';

import 'qr_scan_controller.dart';

class QrScanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QrScanController>(
      () => QrScanController(),
    );
  }
}
