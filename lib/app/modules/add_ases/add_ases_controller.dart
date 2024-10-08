import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../../data/models/assessment_model.dart';
import '../../routes/app_pages.dart';
import '../../services/user_service.dart';
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
  final machineStatusOptions = ['ok', 'ng', 'repairing'];

  @override
  void onInit() {
    super.onInit();
    fetchSubAreas().then((_) => fetchModels()).then((_) => _loadSavedData());
  }

  Future<void> fetchSubAreas() async {
    try {
      final fetchedSubAreas = await _apiService.getSubAreas();
      subAreas.assignAll(fetchedSubAreas);
    } catch (e) {
      print('Error fetching sub areas: $e');
      Get.snackbar('Error', 'Failed to fetch sub areas');
    }
  }

  Future<void> fetchModels() async {
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
  
    // Load saved SubArea, Model, and Machine data
    final savedSubAreaId = _storage.read('subAreaId');
    if (savedSubAreaId != null) {
      selectedSubArea.value = subAreas.firstWhereOrNull((subArea) => subArea.id == savedSubAreaId);
    }
  
    final savedModelId = _storage.read('modelId');
    if (savedModelId != null) {
      selectedModel.value = models.firstWhereOrNull((model) => model.id == savedModelId);
    }
  
    final savedMachineId = _storage.read('machineId');
    if (savedMachineId != null) {
      selectedMachine.value = Machine(
        id: savedMachineId,
        name: _storage.read('machineName') ?? '',
        status: _storage.read('machineStatus') ?? ''
      );
      machineName.value = selectedMachine.value?.name ?? '';
      machineStatus.value = selectedMachine.value?.status;
    }
  }

  void _saveData() {
    _storage.write('shift', selectedShift.value);
    _storage.write('sopNumber', sopNumberController.text);
    _storage.write('machineCodeAsset', machineCodeAssetController.text);
    _storage.write('details', detailsController.text);
    _storage.write('subAreaId', selectedSubArea.value?.id);
    _storage.write('modelId', selectedModel.value?.id);
    _storage.write('machineId', selectedMachine.value?.id);
    _storage.write('machineName', machineName.value);
    _storage.write('machineStatus', machineStatus.value);
  }

  void addAssessment() async {
    if (selectedShift.value != null &&
        selectedSubArea.value != null &&
        selectedModel.value != null &&
        selectedMachine.value != null &&
        sopNumberController.text.isNotEmpty &&
        machineStatus.value != null) {
      final newAssessmentData = {
        'userId': Get.find<UserService>().getUserId() ?? 0,
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
        _saveData(); // Simpan data setelah berhasil menambahkan assessment
        isFormCleared.value = false;
        Get.snackbar('Success', 'Assessment added successfully');
      } catch (e) {
        print('Error adding assessment: $e');
        Get.snackbar('Error', 'Failed to add assessment: $e');
      }
    } else {
      Get.snackbar('Error', 'All fields must be filled');
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