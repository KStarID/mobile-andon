import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/assessment_model.dart';
import '../asesment/asesment_controller.dart';
import '../../../services/service.dart';

class AddAsesController extends GetxController {
  late ApiService _apiService;
  late AuthService _authService;
  late SharedPreferences prefs;

  final machineCodeAssetController = TextEditingController();
  final detailsController = TextEditingController();
  final machineName = TextEditingController();
  
  final selectedShiftId = Rx<String?>(null);
  final selectedMachineId = RxnString();

  final shifts = ['Day', 'Night'];
  final subAreas = <SubArea>[].obs;
  final filteredSubAreas = <SubArea>[].obs;
  final models = <Model>[].obs;
  final filteredModels = <Model>[].obs;

  final machineStatus = Rx<String?>(null);
  final machineStatusOptions = ['OK', 'NG', 'REPAIRING'];

  final subAreaSearchController = TextEditingController();
  final modelSearchController = TextEditingController();
  final sopSearchController = TextEditingController();
  final selectedSubArea = Rx<SubArea?>(SubArea(id: 0, name: '', area: Area(id: 0, name: '')));
  final selectedModel = Rx<Model?>(Model(id: 0, name: '', line: '', isActive: false));

  final assessmentStatus = Rx<String?>(null);

  final sops = <SOP>[].obs;
  final filteredSops = <SOP>[].obs;
  final selectedSop = Rx<SOP?>(null);

  final RxBool isMachineExist = false.obs;

  @override
  void onInit() async {
    super.onInit();
    _apiService = Get.put(ApiService());
    _authService = Get.put(AuthService());
    prefs = await SharedPreferences.getInstance();
    await fetchSubAreas();
    await fetchModels();
    await fetchSops();
    loadSavedData();
    filteredSubAreas.assignAll(subAreas);
    filteredModels.assignAll(models);
    filteredSops.assignAll(sops);
  }

  Future<void> fetchSubAreas() async {
    try {
      final fetchedSubAreas = await _apiService.getSubAreas();
      subAreas.assignAll(fetchedSubAreas);
    } catch (e) {
      print('Error fetching sub areas: $e');
      Get.snackbar('Error', 'Failed to fetch sub area data',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      );
    }
  }

  Future<void> fetchModels() async {
    try {
      final fetchedModels = await _apiService.getModels();
      models.assignAll(fetchedModels);
    } catch (e) {
      print('Error fetching models: $e');
      Get.snackbar('Error', 'Failed to fetch model data',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      );
    }
  }

  Future<void> fetchSops() async {
    try {
      final fetchedSops = await _apiService.getSOPs();
      sops.assignAll(fetchedSops);
    } catch (e) {
      print('Error fetching SOPs: $e');
      Get.snackbar('Error', 'Failed to fetch SOP data',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      );
    }
  }

  void updateShift(String? newValue) {
    selectedShiftId.value = newValue;
    saveData();
  }

  void updateSubArea(SubArea? newValue) {
    selectedSubArea.value = newValue;
    saveData();
  }

  void updateModel(Model? newValue) {
    selectedModel.value = newValue;
    saveData();
  }

  void updateSop(SOP? newValue) {
    selectedSop.value = newValue;
    saveData();
  }

  void fetchMachineDetails() async {
    if (machineCodeAssetController.text.isEmpty) {
      Get.snackbar(
        'Warning', 
        'M/C Code Asset is empty',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.yellow,
        colorText: Colors.black,
      );
      return;
    }

    try {
      final machine = await _apiService.getMachineDetails(machineCodeAssetController.text);
      
      if (machine != null) {
        isMachineExist.value = true;
        selectedMachineId.value = machine.id;
        machineName.text = machine.name;
        updateMachineStatus(machine.status.toUpperCase());
        saveData();
        
        Get.snackbar(
          'Success', 
          'Machine found: ${machine.name}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        isMachineExist.value = false;
        selectedMachineId.value = null;
        machineName.clear();
        Get.snackbar(
          'Info', 
          'Machine not found. You can enter a new machine name.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error fetching machine details: $e');
      isMachineExist.value = false;
      Get.snackbar(
        'Error', 
        'Failed to fetch machine details: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void updateMachineStatus(String? newValue) {
    machineStatus.value = newValue;
    saveData();
  }

  void addAssessment() async {
    if (!validateInputs()) return;

    try {
      final userId = _authService.getUserId();
      if (userId == null) {
        Get.snackbar(
          'Error', 
          'User ID not found',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }

      String machineId;
      
      if (!isMachineExist.value) {
        final machineData = {
          'id': machineCodeAssetController.text,
          'name': machineName.text,
        };
        
        final newMachine = await _apiService.createMachine(machineData);
        if (newMachine == null) {
          throw Exception('Failed to create new machine');
        }
        machineId = machineCodeAssetController.text;
      } else {
        machineId = selectedMachineId.value!;
      }

      final newAssessmentData = {
        'user_id': userId,
        'sub_area_id': selectedSubArea.value!.id,
        'model_id': selectedModel.value!.id,
        'machine_id': machineId,
        'status': machineStatus.value?.toLowerCase() ?? 'ok',
        'sop_id': selectedSop.value!.id,
        'assessment_date': DateTime.now().toIso8601String(),
        'shift': selectedShiftId.value!.toLowerCase(),
        'notes': detailsController.text,
      };

      await Get.put(AsesmentController()).addAssessment(newAssessmentData);
      
      Get.snackbar(
        'Success', 
        'Assessment added successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      await Future.delayed(Duration(seconds: 1));
      Get.offAllNamed('/asesment');
    } catch (e) {
      print('Error in addAssessment: $e');
      Get.snackbar(
        'Error', 
        'Failed to add assessment: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  bool validateInputs() {
    if (selectedShiftId.value == null ||
        selectedSubArea.value == null ||
        selectedModel.value == null ||
        machineCodeAssetController.text.isEmpty ||
        machineName.text.isEmpty ||
        selectedSop.value == null ||
        selectedSop.value!.id == null ||
        machineStatus.value == null) {
      Get.snackbar(
        'Error', 
        'All fields must be filled except Remarks',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }
    return true;
  }

  void clearForm() {
    machineCodeAssetController.clear();
    detailsController.clear();
    machineName.clear();
    selectedShiftId.value = shifts.isNotEmpty ? shifts[0] : null;
    selectedSubArea.value = subAreas.isNotEmpty ? subAreas[0] : null;
    selectedModel.value = models.isNotEmpty ? models[0] : null;
    selectedMachineId.value = null;
    selectedSop.value = sops.isNotEmpty ? sops[0] : null;
    machineStatus.value = machineStatusOptions.isNotEmpty ? machineStatusOptions[0] : null;
    prefs.clear();
  }

  void scanQRCode() async {
    try {
      final result = await Get.toNamed('/qr-scan', arguments: false);
      if (result != null) {
        machineCodeAssetController.text = result;
        fetchMachineDetails();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to scan QR code: $e',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      );
    }
  }

  void saveData() {
    prefs.setString('shiftId', selectedShiftId.value ?? '');
    prefs.setInt('subAreaId', selectedSubArea.value!.id);
    prefs.setInt('modelId', selectedModel.value!.id);
    prefs.setString('machineId', selectedMachineId.value ?? '');
    prefs.setString('sopNumber', selectedSop.value!.id.toString());
    prefs.setString('machineCodeAsset', machineCodeAssetController.text);
    prefs.setString('machineName', machineName.text);
    prefs.setString('machineStatus', machineStatus.value ?? '');
    prefs.setString('details', detailsController.text);
    prefs.setInt('sopId', selectedSop.value?.id ?? 0);
  }

  void loadSavedData() async {
    await fetchSubAreas();
    await fetchModels();
    await fetchSops();

    selectedShiftId.value = prefs.getString('shiftId');
    if (selectedShiftId.value == null || !shifts.contains(selectedShiftId.value)) {
      selectedShiftId.value = shifts.isNotEmpty ? shifts[0] : null;
    }

    int? savedSubAreaId = prefs.getInt('subAreaId');
    selectedSubArea.value = savedSubAreaId != null
        ? subAreas.firstWhereOrNull((sa) => sa.id == savedSubAreaId)
        : (subAreas.isNotEmpty ? subAreas[0] : null);

    int? savedModelId = prefs.getInt('modelId');
    selectedModel.value = savedModelId != null
        ? models.firstWhereOrNull((m) => m.id == savedModelId)
        : (models.isNotEmpty ? models[0] : null);

    int? savedSopId = prefs.getInt('sopId');
    selectedSop.value = savedSopId != null
        ? sops.firstWhereOrNull((s) => s.id == savedSopId)
        : (sops.isNotEmpty ? sops[0] : null);

    selectedMachineId.value = prefs.getString('machineId');
    
    machineCodeAssetController.text = prefs.getString('machineCodeAsset') ?? '';
    machineName.text = prefs.getString('machineName') ?? '';
    machineStatus.value = prefs.getString('machineStatus');
    if (machineStatus.value == null || !machineStatusOptions.contains(machineStatus.value)) {
      machineStatus.value = machineStatusOptions.isNotEmpty ? machineStatusOptions[0] : null;
    }
    detailsController.text = prefs.getString('details') ?? '';

    // Memperbarui daftar yang difilter
    filteredSubAreas.assignAll(subAreas);
    filteredModels.assignAll(models);
    filteredSops.assignAll(sops);
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

  void filterSops(String query) {
    if (query.isEmpty) {
      filteredSops.assignAll(sops);
    } else {
      filteredSops.assignAll(sops.where((sop) =>
          sop.name.toLowerCase().contains(query.toLowerCase())));
    }
  }

  Future<void> createNewMachine(Map<String, dynamic> machineData) async {
    try {
      final createdMachine = await _apiService.createMachine(machineData);
      if (createdMachine != null) {
        machineCodeAssetController.text = createdMachine.id;
        machineName.text = createdMachine.name;
        updateMachineStatus(createdMachine.status.toUpperCase());
        
        Get.snackbar(
          'Success',
          'Machine created successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create machine',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    machineCodeAssetController.dispose();
    detailsController.dispose();
    subAreaSearchController.dispose();
    modelSearchController.dispose();
    sopSearchController.dispose();
    super.onClose();
  }
}
