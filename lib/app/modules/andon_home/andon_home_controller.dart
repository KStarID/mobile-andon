// ignore_for_file: unrelated_type_equality_checks

import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alarm/alarm.dart';
import 'package:vibration/vibration.dart';
import '../../data/models/andon_model.dart';
import '../../services/service.dart';
import '../alarm/alarm_screen.dart';

class AndonHomeController extends GetxController {
  final isLoading = true.obs;
  final isNotificationAllowed = false.obs;
  late List<AlarmSettings> alarms;
  static StreamSubscription<AlarmSettings>? subscription;
  final AndonService _andonService = Get.put(AndonService());
  final RxList<AndonCall> andonCalls = <AndonCall>[].obs;
  final WebSocketService _webSocketService = Get.find<WebSocketService>();

  final messages = <Map<String, dynamic>>[].obs;

  Timer? _timer;

  @override
  Future<void> onInit() async {
    super.onInit();
    await AwesomeNotifications().requestPermissionToSendNotifications();
    await fetchAndonCalls();
    _setupWebSocketListener();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _setupWebSocketListener() {
    _webSocketService.messages.listen((message) {
      try {
        fetchAndonCalls();
      } catch (e) {
        print('Error processing message: $e');
      }
    });
  }

  Future<void> fetchAndonCalls() async {
    try {
      isLoading.value = true;
      await Future.delayed(Duration(seconds: 1));
      final calls = await _andonService.getAndonsByRoleActive();
      final currentUserId = Get.put(ApiService()).getUserId();
      andonCalls.assignAll(calls.where((call) {
        print(calls);
        if (call.pic != null) {
          return call.pic?.id == currentUserId;
        }
        return true; 
      }));
    } catch (e) {
      print('Error fetching andon calls: $e');
      Get.snackbar(
        'Error', 
        'Gagal memuat data Andon',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String removeLetters(String andonNumber) {
    final match = RegExp(r'(\d+)').firstMatch(andonNumber);
    return match != null ? match.group(0)! : andonNumber; 
  }

  Future<void> processQRScanResult(String scannedCode, AndonCall call) async {
    final andonNumber = call.andonNumber;
    final cleanAndonNumber = removeLetters(andonNumber);
    if (scannedCode == cleanAndonNumber) {
      try {
          final scan = await _andonService.andonscanner(call.id);
          if (scan['success'] == true) {
            Future.delayed(Duration(seconds: 1));
            Get.offAllNamed('/repairing', arguments: {
              'andonId': call.id,
            });
          } else {
            // Menggunakan dialog untuk error
            await Get.dialog(
              AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Error', style: TextStyle(color: Colors.red)),
                  ],
                ),
                content: Text(
                  'Failed to process Andon scan: ${scan['message']}',
                  style: TextStyle(fontSize: 16),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('OK', style: TextStyle(fontSize: 16)),
                  ),
                ],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              barrierDismissible: false, // Harus klik OK untuk menutup
            );
          }
          
      } catch (e) {
        // Error handling dengan dialog
        await Get.dialog(
          AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 10),
                Text('Error', style: TextStyle(color: Colors.red)),
              ],
            ),
            content: Text(
              'Failed to process Andon scan: $e',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('OK', style: TextStyle(fontSize: 16)),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          barrierDismissible: false,
        );
      }
    } else {
      // Invalid QR code dialog
      await Get.dialog(
        AlertDialog(
          title: Row(
            children: [
              Icon(Icons.qr_code, color: Colors.red),
              SizedBox(width: 10),
              Text('Invalid QR Code', style: TextStyle(color: Colors.red)),
            ],
          ),
          content: Text(
            'Please scan the correct QR code.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('OK', style: TextStyle(fontSize: 16)),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        barrierDismissible: false,
      );
    }
  }

  void scheduleAlarm(Map<String, dynamic> message) async {
    final alarmSettings = AlarmSettings(
      id: 42,
      dateTime: DateTime.now().add(Duration(seconds: 1)),
      assetAudioPath: 'assets/alarm.wav',
      loopAudio: true,
      vibrate: true,
      volume: 1,
      fadeDuration: 0.0,
      warningNotificationOnKill: true,
      androidFullScreenIntent: true,
      notificationSettings: NotificationSettings(
        title: 'Andon System Alert!',
        body: 'New task assigned to ${Get.find<ApiService>().getRole()} : ${message['line']} - ${message['sop_number']}',
        icon: 'assets/icon/oppo-logo.png',
      ),
    );

    try {
      await Alarm.set(alarmSettings: alarmSettings);
      await Get.to(() => AlarmScreen(alarmSettings: alarmSettings));
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(pattern: [500, 1000, 500, 2000], repeat: 1);
      }
      loadAlarms();
    } catch (e) {
      print('Failed to schedule alarm: $e');
    }
  }

  void loadAlarms() {
    alarms = Alarm.getAlarms();
    alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
  }

    Future<void> vibrate() async {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate();
      }
    }

  Future<void> updateMessageStatus(String sopNumber, String status) async {
    try {
      final index = messages.indexWhere((message) => message['sop_number'] == sopNumber);
      if (index != -1) {
        messages[index]['status'] = status;
        update();
        
        // Tambahkan notifikasi sukses
        Get.snackbar(
          'Success', 
          'Status updated successfully to $status',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
          isDismissible: true,
          overlayBlur: 0,
          overlayColor: Colors.transparent,
        );
      }
    } catch (e) {
      print('Error updating message status: $e');
      Get.snackbar(
        'Error', 
        'Failed to update status',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
        isDismissible: true,
        overlayBlur: 0,
        overlayColor: Colors.transparent,
      );
    }
  }
}
