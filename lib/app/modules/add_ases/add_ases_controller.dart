import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/assessment_model.dart';
import '../../routes/app_pages.dart';
import '../asesment/asesment_controller.dart';
import '../../services/service.dart';

class AddAsesController extends GetxController {
  late ApiService _apiService;
  late AuthService _authService;
  late SharedPreferences prefs;

  final sopNumberController = TextEditingController();
  final machineCodeAssetController = TextEditingController();
  final detailsController = TextEditingController();

  final selectedShiftId = Rx<String?>(null);
  final selectedSubAreaId = Rxn<int>();
  final selectedModelId = Rxn<int>();
  final selectedMachineId = RxnString();

  final shifts = ['Day', 'Night'];
  final subAreas = <SubArea>[].obs;
  final filteredSubAreas = <SubArea>[].obs;
  final models = <Model>[].obs;
  final filteredModels = <Model>[].obs;

  final machineName = ''.obs;
  final machineStatus = Rx<String?>(null);
  final machineStatusOptions = ['ok', 'ng', 'repairing'];

  final subAreaSearchController = TextEditingController();
  final modelSearchController = TextEditingController();

  final selectedSubArea = Rx<SubArea?>(null);
  final selectedModel = Rx<Model?>(null);

  @override
  void onInit() async {
    super.onInit();
    _apiService = Get.put(ApiService());
    _authService = Get.put(AuthService());
    prefs = await SharedPreferences.getInstance();
    await fetchSubAreas();
    await fetchModels();
    loadSavedData();
    filteredSubAreas.assignAll(subAreas);
    filteredModels.assignAll(models);
  }

  Future<void> fetchSubAreas() async {
    try {
      final fetchedSubAreas = await _apiService.getSubAreas();
      subAreas.assignAll(fetchedSubAreas);
    } catch (e) {
      print('Error fetching sub areas: $e');
      Get.snackbar('Error', 'Gagal mengambil data sub area');
    }
  }

  Future<void> fetchModels() async {
    try {
      final fetchedModels = await _apiService.getModels();
      models.assignAll(fetchedModels);
    } catch (e) {
      print('Error fetching models: $e');
      Get.snackbar('Error', 'Gagal mengambil data model');
    }
  }

  void updateShift(String? newValue) {
    selectedShiftId.value = newValue;
    saveData();
  }

  void updateSubArea(SubArea? newValue) {
    selectedSubArea.value = newValue;
    selectedSubAreaId.value = newValue?.id;
    saveData();
  }

  void updateModel(Model? newValue) {
    selectedModel.value = newValue;
    selectedModelId.value = newValue?.id;
    saveData();
  }

  void fetchMachineDetails() async {
    if (machineCodeAssetController.text.isNotEmpty) {
      try {
        final machine = await _apiService.getMachineDetails(machineCodeAssetController.text);
        selectedMachineId.value = machine.id;
        machineName.value = machine.name;
        updateMachineStatus(machine.status);
        saveData();
      } catch (e) {
        print('Error fetching machine details: $e');
        Get.snackbar('Error', 'Gagal mengambil detail mesin');
      }
    }
  }

  void updateMachineStatus(String? newValue) {
    machineStatus.value = newValue;
    saveData();
  }

  void addAssessment() async {
    if (selectedShiftId.value == null ||
        selectedSubAreaId.value == null ||
        selectedModelId.value == null ||
        selectedMachineId.value == null ||
        sopNumberController.text.isEmpty ||
        machineStatus.value == null) {
      Get.snackbar('Error', 'Semua field harus diisi kecuali notes');
      return;
    }

    final userId = _authService.getUserId();
    if (userId == null) {
      Get.snackbar('Error', 'User ID tidak ditemukan');
      return;
    }

    final newAssessmentData = {
      'userId': userId,
      'subAreaId': selectedSubAreaId.value!,
      'modelId': selectedModelId.value!,
      'machineId': selectedMachineId.value!,
      'status': machineStatus.value!,
      'sop_number': sopNumberController.text,
      'assessmentDate': DateTime.now().toIso8601String(),
      'shift': selectedShiftId.value!,
      'notes': detailsController.text.isNotEmpty ? detailsController.text : null,
    };

    try {
      await Get.find<AsesmentController>().addAssessment(newAssessmentData);
      Get.snackbar('Success', 'Assessment successfully added');
      Get.offAllNamed('/asesment');
    } catch (e) {
      print('Error adding assessment: $e');
      Get.snackbar('Success', 'Assessment successfully added');
      Get.offAllNamed('/asesment');
    }
  }

  void clearForm() {
    sopNumberController.clear();
    machineCodeAssetController.clear();
    detailsController.clear();
    selectedShiftId.value = null;
    selectedSubAreaId.value = null;
    selectedModelId.value = null;
    selectedMachineId.value = null;
    machineName.value = '';
    machineStatus.value = null;
    prefs.clear();
  }

  void scanQRCode() async {
    try {
      final result = await Get.toNamed(Routes.QR_SCAN, arguments: false);
      if (result != null) {
        machineCodeAssetController.text = result;
        fetchMachineDetails();
      }
    } catch (e) {
      print('Error scanning QR code: $e');
      Get.snackbar('Error', 'Gagal memindai kode QR: $e');
    }
  }

  void saveData() {
    prefs.setString('shiftId', selectedShiftId.value ?? '');
    prefs.setInt('subAreaId', selectedSubAreaId.value ?? 0);
    prefs.setInt('modelId', selectedModelId.value ?? 0);
    prefs.setString('machineId', selectedMachineId.value ?? '');
    prefs.setString('sopNumber', sopNumberController.text);
    prefs.setString('machineCodeAsset', machineCodeAssetController.text);
    prefs.setString('machineName', machineName.value);
    prefs.setString('machineStatus', machineStatus.value ?? '');
    prefs.setString('details', detailsController.text);
  }

  void loadSavedData() {
    selectedShiftId.value = prefs.getString('shiftId');
    if (selectedShiftId.value == null || !shifts.contains(selectedShiftId.value)) {
      selectedShiftId.value = shifts.isNotEmpty ? shifts.first : null;
    }

    selectedSubAreaId.value = prefs.getInt('subAreaId');
    if (selectedSubAreaId.value == null || !subAreas.any((sa) => sa.id == selectedSubAreaId.value)) {
      selectedSubAreaId.value = subAreas.isNotEmpty ? subAreas.first.id : null;
    }

    selectedModelId.value = prefs.getInt('modelId');
    if (selectedModelId.value == null || !models.any((m) => m.id == selectedModelId.value)) {
      selectedModelId.value = models.isNotEmpty ? models.first.id : null;
    }

    selectedMachineId.value = prefs.getString('machineId');
    
    sopNumberController.text = prefs.getString('sopNumber') ?? '';
    machineCodeAssetController.text = prefs.getString('machineCodeAsset') ?? '';
    machineName.value = prefs.getString('machineName') ?? '';
    machineStatus.value = prefs.getString('machineStatus');
    if (machineStatus.value == null || !machineStatusOptions.contains(machineStatus.value)) {
      machineStatus.value = machineStatusOptions.isNotEmpty ? machineStatusOptions.first : null;
    }
    detailsController.text = prefs.getString('details') ?? '';
  }

  void filterSubAreas(String query) {
    if (query.isEmpty) {
      filteredSubAreas.assignAll(subAreas);
    } else {
      filteredSubAreas.assignAll(subAreas.where((subArea) =>
          subArea.name.toLowerCase().contains(query.toLowerCase())));
    }
  }

  void filterModels(String query) {
    if (query.isEmpty) {
      filteredModels.assignAll(models);
    } else {
      filteredModels.assignAll(models.where((model) =>
          model.name.toLowerCase().contains(query.toLowerCase())));
    }
  }

  @override
  void onClose() {
    sopNumberController.dispose();
    machineCodeAssetController.dispose();
    detailsController.dispose();
    subAreaSearchController.dispose();
    modelSearchController.dispose();
    super.onClose();
  }
}