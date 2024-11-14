import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/andon_model.dart';
import '../../services/service.dart';

class AndonHistoryDetailsController extends GetxController {
  final AndonService _andonService = Get.find<AndonService>();
  final andonCall = Rx<AndonCall?>(null);
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    final String andonId = Get.parameters['id'] ?? '';
    if (andonId.isNotEmpty) {
      fetchAndonDetails(andonId);
    } else {
      isLoading(false);
    }
  }

  Future<void> fetchAndonDetails(String andonId) async {
    try {
      isLoading(true);
      final result = await _andonService.getAndonHistoryByAndonId(andonId);
      andonCall.value = result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch andon details',
        duration: Duration(seconds: 3),
        isDismissible: true,
        overlayBlur: 0,
        overlayColor: Colors.transparent,
      );
    } finally {
      isLoading(false);
    }
  }
}
