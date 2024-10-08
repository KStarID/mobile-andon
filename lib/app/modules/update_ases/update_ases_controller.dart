import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/assessment_model.dart';
import '../../services/service.dart';
import '../asesment/asesment_controller.dart';

class UpdateAsesController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final formKey = GlobalKey<FormState>();
  
  final shiftController = TextEditingController();
  final sopNumberController = TextEditingController();
  final machineCodeAssetController = TextEditingController();
  final detailsController = TextEditingController();

  final selectedShift = Rx<String?>(null);
  final selectedSubArea = Rx<SubArea?>(null);
  final selectedModel = Rx<Model?>(null);
  final selectedMachine = Rx<Machine?>(null);
  final machineStatus = Rx<String?>(null);

  final shifts = ['Day', 'Night'];
  final subAreas = <SubArea>[].obs;
  final models = <Model>[].obs;
  final machineStatusOptions = ['ok', 'repairing', 'breakdown'];

  final assessment = Rx<Assessment?>(null);

  @override
  void onInit() {
    super.onInit();
    final Assessment? arg = Get.arguments as Assessment?;
    if (arg != null) {
      assessment.value = arg;
      populateForm();
    } else {
      print('No assessment data received');
      Get.snackbar('Error', 'No assessment data available');
    }
    fetchSubAreas();
    fetchModels();
  }

  void fetchSubAreas() async {
    try {
      final fetchedSubAreas = await _apiService.getSubAreas();
      subAreas.assignAll(fetchedSubAreas);
      // Setelah mengambil subAreas, coba tetapkan selectedSubArea lagi
      if (assessment.value != null) {
        selectedSubArea.value = subAreas.firstWhereOrNull((subArea) => subArea.id == assessment.value!.subArea.id);
      }
    } catch (e) {
      print('Error fetching sub areas: $e');
      Get.snackbar('Error', 'Failed to fetch sub areas');
    }
  }

  void fetchModels() async {
    try {
      final fetchedModels = await _apiService.getModels();
      models.assignAll(fetchedModels);
      // Setelah mengambil models, coba tetapkan selectedModel lagi
      if (assessment.value != null) {
        selectedModel.value = models.firstWhereOrNull((model) => model.id == assessment.value!.model.id);
      }
    } catch (e) {
      print('Error fetching models: $e');
      Get.snackbar('Error', 'Failed to fetch models');
    }
  }

  void populateForm() {
    if (assessment.value != null) {
      selectedShift.value = assessment.value!.shift.capitalize;
      sopNumberController.text = assessment.value!.sopNumber;
      machineCodeAssetController.text = assessment.value!.machine.id;
      detailsController.text = assessment.value!.notes ?? '';
      
      // Tunggu hingga subAreas dan models diisi sebelum menetapkan nilai
      ever(subAreas, (_) {
        selectedSubArea.value = subAreas.firstWhereOrNull((subArea) => subArea.id == assessment.value!.subArea.id);
      });
      
      ever(models, (_) {
        selectedModel.value = models.firstWhereOrNull((model) => model.id == assessment.value!.model.id);
      });
      
      selectedMachine.value = assessment.value!.machine;
      machineStatus.value = assessment.value!.machine.status;
    }
  }

  void updateShift(String? value) {
    selectedShift.value = value;
  }

  void updateSubArea(SubArea? value) {
    selectedSubArea.value = value;
  }

  void updateModel(Model? value) {
    selectedModel.value = value;
  }

  void updateMachineStatus(String? value) {
    machineStatus.value = value;
  }

  void updateAssessment() async {
    if (formKey.currentState!.validate()) {
      try {
        final updatedAssessmentData = {
          'shift': selectedShift.value!.toLowerCase(),
          'sop_number': sopNumberController.text,
          'subAreaId': selectedSubArea.value!.id,
          'modelId': selectedModel.value!.id,
          'machineId': selectedMachine.value!.id,
          'status': machineStatus.value,
          'notes': detailsController.text,
          'assessmentDate': DateTime.now().toIso8601String(),
        };

        final updatedAssessment = await _apiService.updateAssessment(assessment.value!.id, updatedAssessmentData);
        Get.find<AsesmentController>().updateAssessmentList(updatedAssessment);
        Get.back();
        Get.snackbar('Success', 'Assessment updated successfully');
      } catch (e) {
        print('Error updating assessment: $e');
        Get.snackbar('Error', 'Failed to update assessment: $e');
      }
    }
  }

  @override
  void onClose() {
    shiftController.dispose();
    sopNumberController.dispose();
    machineCodeAssetController.dispose();
    detailsController.dispose();
    super.onClose();
  }
}
