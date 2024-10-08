import 'package:get/get.dart';

class UserService extends GetxService {
  final Rx<String?> username = Rx<String?>(null);
  final Rx<int?> userId = Rx<int?>(null);
  
  void setUsername(String name) {
    username.value = name;
  }

  void setUserId(int id) {
    userId.value = id;
  }

  String? getUsername() {
    return username.value;
  }

  int? getUserId() {
    return userId.value;
  }
}
