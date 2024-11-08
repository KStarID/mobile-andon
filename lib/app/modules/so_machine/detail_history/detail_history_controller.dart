import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/assessment_model.dart';
import '../../../services/service.dart';

class DetailHistoryController extends GetxController {
  late final ApiService _apiService;
  final assessment = Rx<Assessment?>(null);
  final historyList = <Assessment>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _apiService = Get.put(ApiService());
    final Assessment? arg = Get.arguments;
    if (arg != null) {
      assessment.value = arg;
      fetchAssessmentHistory(arg.machine.id);
    }
  }

  void fetchAssessmentHistory(String machineId) async {
    try {
      isLoading(true);
      final history = await _apiService.getAssessmentHistoryByMachineId(machineId);
      history.sort((a, b) => b.id!.compareTo(a.id!));
      historyList.assignAll(history);
      if (historyList.isNotEmpty) {
        assessment.value = historyList.first;
      }
    } catch (e) {
      Get.snackbar(
      'Error', 
      'Failed to fetch assessment history. Please try again.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      icon: Icon(Icons.error_outline, color: Colors.white),
      margin: EdgeInsets.all(16),
      borderRadius: 8,
      duration: Duration(seconds: 3),
    );
    } finally {
      isLoading(false);
    }
  }
}
