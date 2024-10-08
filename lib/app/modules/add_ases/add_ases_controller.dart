import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../../data/models/assessment_model.dart';
import '../../routes/app_pages.dart';
import '../asesment/asesment_controller.dart';
import '../../services/service.dart';

class AddAsesController extends GetxController {
  final ApiService _apiService = ApiService();
  final shiftController = TextEditingController();
  final sopNumberController = TextEditingController();
  final machineCodeAssetController = TextEditingController();
  final detailsController = TextEditingController();

  final isFormCleared = true.obs;
  final _storage = GetStorage();

  final selectedShift = Rx<String?>(null);
  final selectedSubArea = Rx<SubArea?>(null);
  final selectedModel = Rx<Model?>(null);
  final selectedMachine = Rx<Machine?>(null);

  final shifts = ['Day', 'Night'];
  final subAreas = <SubArea>[].obs;
  final models = <Model>[].obs;

  // Tambahkan ini
  final machineName = ''.obs;
  final machineStatus = Rx<String?>(null);
  final machineStatusOptions = ['ok', 'repairing', 'breakdown'];

  @override
  void onInit() {
    super.onInit();
    fetchSubAreas();
    fetchModels();
    _loadSavedData();
  }

  void fetchSubAreas() async {
    try {
      final fetchedSubAreas = await _apiService.getSubAreas();
      subAreas.assignAll(fetchedSubAreas);
    } catch (e) {
      print('Error fetching sub areas: $e');
      Get.snackbar('Error', 'Failed to fetch sub areas');
    }
  }

  void fetchModels() async {
    try {
      final fetchedModels = await _apiService.getModels();
      models.assignAll(fetchedModels);
    } catch (e) {
      print('Error fetching models: $e');
      Get.snackbar('Error', 'Failed to fetch models');
    }
  }

  void updateShift(String? newValue) {
    if (newValue != null && newValue != selectedShift.value) {
      selectedShift.value = newValue;
      shiftController.text = newValue;
    }
  }

  void updateSubArea(SubArea? newValue) {
    if (newValue != null) {
      selectedSubArea.value = newValue;
    }
  }

  void updateModel(Model? newValue) {
    if (newValue != null) {
      selectedModel.value = newValue;
    }
  }

  void fetchMachineDetails() async {
    if (machineCodeAssetController.text.isNotEmpty) {
      try {
        final machine = await _apiService.getMachineDetails(machineCodeAssetController.text);
        selectedMachine.value = machine;
        machineName.value = machine.name;
        updateMachineStatus(machine.status);
      } catch (e) {
        print('Error fetching machine details: $e');
        Get.snackbar('Error', 'Failed to fetch machine details');
      }
    }
  }

  void updateMachineStatus(String? newValue) {
    if (newValue != null && machineStatusOptions.contains(newValue)) {
      machineStatus.value = newValue;
    } else {
      machineStatus.value = null;
    }
  }

  void _loadSavedData() {
    final savedShift = _storage.read('shift');
    if (savedShift != null && shifts.contains(savedShift)) {
      selectedShift.value = savedShift;
      shiftController.text = savedShift;
    }
    sopNumberController.text = _storage.read('sopNumber') ?? '';
    machineCodeAssetController.text = _storage.read('machineCodeAsset') ?? '';
    detailsController.text = _storage.read('details') ?? '';
  }

  void _saveData() {
    _storage.write('shift', selectedShift.value);
    _storage.write('sopNumber', sopNumberController.text);
    _storage.write('machineCodeAsset', machineCodeAssetController.text);
    _storage.write('details', detailsController.text);
  }

  void addAssessment() async {
    if (selectedShift.value != null &&
        selectedSubArea.value != null &&
        selectedModel.value != null &&
        selectedMachine.value != null &&
        sopNumberController.text.isNotEmpty &&
        machineStatus.value != null) {
      final newAssessmentData = {
        'userId': 1, // Anda mungkin perlu menyesuaikan ini
        'subAreaId': selectedSubArea.value!.id,
        'modelId': selectedModel.value!.id,
        'machineId': selectedMachine.value!.id,
        'status': machineStatus.value,
        'sop_number': sopNumberController.text,
        'assessmentDate': DateTime.now().toIso8601String().split('T')[0],
        'shift': selectedShift.value!.toLowerCase(),
        'notes': detailsController.text,
      };

      try {
        await Get.find<AsesmentController>().addAssessment(newAssessmentData);
        isFormCleared.value = false;
        Get.offAllNamed('/asesment');
      } catch (e) {
        print('Error adding assessment: $e');
        Get.offAllNamed('/asesment');
      }
    } else {
      Get.snackbar('Error', 'Semua field harus diisi');
    }
  }

  void clearForm() {
    shiftController.clear();
    sopNumberController.clear();
    machineCodeAssetController.clear();
    detailsController.clear();
    selectedShift.value = null;
    selectedSubArea.value = null;
    selectedModel.value = null;
    selectedMachine.value = null;
    machineName.value = ''; // Tambahkan ini
    machineStatus.value = null; // Tambahkan ini
    _storage.erase();
    isFormCleared.value = true;
  }

  void scanQRCode() async {
    final result = await Get.toNamed(Routes.QR_SCAN, arguments: false);
    if (result != null) {
      machineCodeAssetController.text = result;
      fetchMachineDetails();
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