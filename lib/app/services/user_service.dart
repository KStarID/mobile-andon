import 'package:get/get.dart';

class UserService extends GetxService {
  final Rx<String?> username = Rx<String?>(null);

  void setUsername(String name) {
    username.value = name;
  }

  String? getUsername() {
    return username.value;
  }
}
