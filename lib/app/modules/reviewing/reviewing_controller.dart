import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/andon_model.dart';
import '../../services/service.dart';

class ReviewingController extends GetxController {
  final AndonService _andonService = Get.find<AndonService>();
  final isLoading = true.obs;
  final repairingCalls = <AndonCall>[].obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    isLoading(true);
    fetchRepairingCalls();
    AwesomeNotifications().requestPermissionToSendNotifications();
    _startPeriodicRefresh();
    isLoading(false);
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _startPeriodicRefresh() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      fetchRepairingCalls();
    });
  }

  Future<void> fetchRepairingCalls() async {
    try {
      final userId = Get.put(ApiService()).getUserId();
      final calls = await _andonService.getCallbyLeader(userId);
      repairingCalls.assignAll(calls);
    } catch (e) {
      print('Error fetching repairing calls: $e');
    }
  }

  void initializeNotifications() {
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'Review',
          channelName: 'Review Andon',
          channelDescription: 'Please review the Andon',
          defaultColor: Colors.blue,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          defaultPrivacy: NotificationPrivacy.Private,
          enableVibration: true,
          enableLights: true,
        )
      ],
      debug: true,
    );

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'Review',
        actionType: ActionType.Default,
        title: 'Review Andon',
        body: 'Please review the Andon',
        timeoutAfter: Duration(seconds: 5),
        autoDismissible: true,
      )
    );
  }

  Future<void> reviewRepairing(int andonId, String status) async {
    try {
      await _andonService.LeaderReview(andonId, status);
      await fetchRepairingCalls(); // Refresh the list after review
      Get.back(); // Close the confirmation dialog
      Get.snackbar(
        'Success', 
        'Review submitted successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
        isDismissible: true,
        overlayBlur: 0,
        overlayColor: Colors.transparent,
      );
    } catch (e) {
      print('Error reviewing repairing: $e');
      Get.snackbar(
        'Error', 
        'Failed to submit review',
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

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    // Arahkan ke tampilan reviewing
    Get.toNamed('/reviewing');
  }
}
