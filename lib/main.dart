import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/routes/app_pages.dart';
import 'app/services/service.dart';
import 'app/services/user_service.dart';

void main() async {
  await GetStorage.init();
  Get.put(AuthService());
  Get.put(UserService());
  runApp(
    GetMaterialApp(
      title: "Andon System",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
