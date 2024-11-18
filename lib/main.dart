import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/modules/reviewing/reviewing_controller.dart';
import 'app/routes/app_pages.dart';
import 'app/services/service.dart';
import 'app/services/user_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestPermissions();
  
  tz.initializeTimeZones();

  Get.put(AuthService());
  Get.put(UserService());
  Get.put(WebSocketService());
  await AwesomeNotifications().cancelAll();
  
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: ReviewingController.onActionReceivedMethod,
  );

  // Cek first run dan clear cache
  await checkFirstRun();

  runApp(
    GetMaterialApp(
      title: "Andon System",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}

Future<void> requestPermissions() async {
  // Daftar izin yang diperlukan
  Map<Permission, PermissionStatus> statuses = await [
    Permission.systemAlertWindow,
    Permission.accessNotificationPolicy,
    Permission.notification,
  ].request();

  // Cek status masing-masing izin
  statuses.forEach((permission, status) async {
    if (status.isDenied) {
      if (await permission.shouldShowRequestRationale) {
        // Tampilkan penjelasan mengapa izin diperlukan (opsional)
        showPermissionRationaleDialog(permission);
      } else {
        // Minta izin lagi
        await permission.request();
      }
    }
    
    // Jika izin ditolak secara permanen, buka pengaturan aplikasi
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
  });
}

void showPermissionRationaleDialog(Permission permission) {
  Get.dialog(
    AlertDialog(
      title: Text('Izin Diperlukan'),
      content: Text(_getPermissionRationaleMessage(permission)),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Batal'),
        ),
        TextButton(
          onPressed: () async {
            Get.back();
            await permission.request();
          },
          child: Text('Izinkan'),
        ),
      ],
    ),
  );
}

String _getPermissionRationaleMessage(Permission permission) {
  switch (permission) {
    case Permission.notification:
      return 'Izin notifikasi diperlukan untuk menampilkan alarm';
    case Permission.accessNotificationPolicy:
      return 'Izin ini diperlukan untuk mengatur kebijakan notifikasi';
    case Permission.ignoreBatteryOptimizations:
      return 'Izin ini diperlukan agar alarm tetap berfungsi saat mode hemat baterai aktif';
    case Permission.scheduleExactAlarm:
      return 'Izin ini diperlukan untuk menjadwalkan alarm dengan tepat waktu';
    case Permission.systemAlertWindow:
      return 'Izin ini diperlukan untuk menampilkan alarm di layar utama';
    default:
      return 'Izin ini diperlukan untuk fungsi aplikasi';
  }
}

Future<void> checkFirstRun() async {
  final prefs = await SharedPreferences.getInstance();
  bool isFirstRun = prefs.getBool('is_first_run') ?? true;
  
  if (isFirstRun) {
    // Clear semua cache
    await clearAppCache();
    // Set first run menjadi false
    await prefs.setBool('is_first_run', false);
  }
}

Future<void> clearAppCache() async {
  
  // Hapus cache notifications
  await AwesomeNotifications().cancelAll();
  
  // Hapus local storage
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  
}
