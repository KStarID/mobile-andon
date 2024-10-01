import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void login() {
    // Implementasi logika login di sini
    // Misalnya, verifikasi kredensial dan hubungkan ke MQTT
    print('Username: ${usernameController.text}');
    print('Password: ${passwordController.text}');
    // Jika login berhasil, arahkan ke halaman utama
    // Get.offAllNamed(Routes.HOME);
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
