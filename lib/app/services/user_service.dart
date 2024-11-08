import 'package:get/get.dart';

class UserService extends GetxService {
  final Rx<String?> username = Rx<String?>(null);
  final Rx<int?> userId = Rx<int?>(null);
  final Rx<String?> nama = Rx<String?>(null);
  
  void setUsername(String name) {
    username.value = name;
  }

  void setUserId(int id) {
    userId.value = id;
  }

  void setNama(String name) {
    nama.value = name;
  }

  String? getUsername() {
    return username.value;
  }

  int? getUserId() {
    return userId.value;
  }

  String? getNama() {
    return nama.value;
  }
}
