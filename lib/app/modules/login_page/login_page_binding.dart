import 'package:get/get.dart';
import 'package:testcli/app/modules/login_page/login_page_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(
      () => LoginController(),
    );
  }
}
