import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/models/assessment_model.dart';
import '../../../services/service.dart';
import '../asesment/asesment_controller.dart';

class UpdateAsesController extends GetxController {
  late ApiService _apiService;
  late AuthService _authService;

  final formKey = GlobalKey<FormState>();
  
  final shiftController = TextEditingController();
  final machineCodeAssetController = TextEditingController();
  final detailsController = TextEditingController();
  final subAreaSearchController = TextEditingController();
  final modelSearchController = TextEditingController();
  final sopSearchController = TextEditingController();

  final selectedShift = Rx<String?>(null);
  final selectedSubArea = Rx<SubArea?>(null);
  final selectedModel = Rx<Model?>(null);
  final selectedSop = Rx<SOP?>(null);
  final selectedMachine = Rx<Machine?>(null);
  final machineStatus = Rx<String?>(null);

  final shifts = ['Day', 'Night'];
  final subAreas = <SubArea>[].obs;
  final models = <Model>[].obs;
  final sops = <SOP>[].obs;
  final machineStatusOptions = ['ok', 'ng', 'repairing'];

  final assessment = Rx<Assessment?>(null);
  final assessmentStatus = Rx<String?>(null);

  final filteredSubAreas = <SubArea>[].obs;
  final filteredModels = <Model>[].obs;
  final filteredSops = <SOP>[].obs;

  // Tambahkan ini

  @override
  void onInit() async {
    super.onInit();
    _apiService = Get.put(ApiService());
    _authService = Get.put(AuthService());
    final Assessment? arg = Get.arguments as Assessment?;
    if (arg != null) {
      assessment.value = arg;
      populateForm();
    } else {
      Get.snackbar(
        'Error', 
        'No assessment data available. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        icon: Icon(Icons.error_outline, color: Colors.white),
        margin: EdgeInsets.all(16),
        borderRadius: 8,
        duration: Duration(seconds: 3),
        isDismissible: true,
        overlayBlur: 0,
        overlayColor: Colors.transparent,
      );
    }
    await fetchSubAreas();
    await fetchModels();
    await fetchSops();
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
      duration: Duration(seconds: 3),
      isDismissible: true,
      overlayBlur: 0,
      overlayColor: Colors.transparent,
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
      duration: Duration(seconds: 3),
      isDismissible: true,
      overlayBlur: 0,
      overlayColor: Colors.transparent,
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
      duration: Duration(seconds: 3),
      isDismissible: true,
      overlayBlur: 0,
      overlayColor: Colors.transparent,
      );
    }
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

  void populateForm() {
    if (assessment.value != null) {
      selectedShift.value = assessment.value!.shift.capitalize;
      machineCodeAssetController.text = assessment.value!.machine.id;
      detailsController.text = assessment.value!.notes ?? '';
      
      ever(subAreas, (_) {
        selectedSubArea.value = subAreas.firstWhereOrNull((subArea) => subArea.id == assessment.value!.subArea.id);
      });
      
      ever(models, (_) {
        selectedModel.value = models.firstWhereOrNull((model) => model.id == assessment.value!.model.id);
      });

      ever(sops, (_) {
        selectedSop.value = sops.firstWhereOrNull((sop) => sop.id == assessment.value!.sop.id);
      });
      
      selectedMachine.value = assessment.value!.machine;
      assessmentStatus.value = assessment.value!.status.toLowerCase();
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

  void updateSop(SOP? value) {
    selectedSop.value = value;
  }

  void updateAssessmentStatus(String? value) {
    assessmentStatus.value = value;
  }

  void updateAssessment() async {
  if (formKey.currentState!.validate()) {
    try {
      // Prepare updated assessment data
      final userId = _authService.getUserId();
      if (userId == null) {
        Get.snackbar('Error', 'User ID not Found',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        icon: Icon(Icons.error_outline, color: Colors.white),
        margin: EdgeInsets.all(16),
        borderRadius: 8,
        duration: Duration(seconds: 3),
        isDismissible: true,
        overlayBlur: 0,
        overlayColor: Colors.transparent,
        );
        return;
      }

      final updatedAssessmentData = {
        'user_id': userId,
        'shift': selectedShift.value!.toLowerCase(),
        'sop_id': selectedSop.value!.id,
        'sub_area_id': selectedSubArea.value!.id,
        'model_id': selectedModel.value!.id,
        'machine_id': selectedMachine.value!.id,
        'status': assessmentStatus.value!.toLowerCase(),
        'notes': detailsController.text,
        'assessment_date': DateTime.now().toIso8601String(),
      };

      // Update the assessment data
      await Get.put(AsesmentController()).addAssessment(updatedAssessmentData);

      // Show success snackbar and navigate back
      Get.snackbar(
        'Success', 
        'Assessment updated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green[400],
        colorText: Colors.white,
        icon: Icon(Icons.check_circle, color: Colors.white),
        margin: EdgeInsets.all(16),
        borderRadius: 8,
        duration: Duration(seconds: 3),
        isDismissible: true,
        overlayBlur: 0,
        overlayColor: Colors.transparent,
      );

      Get.offAllNamed('/asesment');
    } catch (e) {
      Get.snackbar(
        'Success', 
        'Assessment updated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green[400],
        colorText: Colors.white,
        icon: Icon(Icons.check_circle, color: Colors.white),
        margin: EdgeInsets.all(16),
        borderRadius: 8,
        duration: Duration(seconds: 3),
        isDismissible: true,
        overlayBlur: 0,
        overlayColor: Colors.transparent,
      );

      Get.offAllNamed('/asesment');
    }
  }
  }


  @override
  void onClose() {
    shiftController.dispose();
    machineCodeAssetController.dispose();
    detailsController.dispose();
    subAreaSearchController.dispose();
    modelSearchController.dispose();
    sopSearchController.dispose();
    super.onClose();
  }
}