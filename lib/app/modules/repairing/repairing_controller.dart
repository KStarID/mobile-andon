import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/andon_model.dart';
import '../../services/service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home/home_controller.dart';

class RepairingController extends GetxController {
  final _andonService = Get.find<AndonService>();
  final selectedLeader = Rx<Leader?>(null);
  final leaders = <Leader>[].obs;
  final filteredLeaders = <Leader>[].obs;
  final selectedShift = Rx<String?>(null);
  final shifts = ['Day', 'Night'];
  final role = Rx<String?>(null);
  final canAssess = false.obs;
  late HomeController _homeController;
  final leaderSearchController = TextEditingController();
  final problemController = TextEditingController();
  final solutionController = TextEditingController();
  final remarksController = TextEditingController();

  late SharedPreferences prefs;

  @override
  void onInit() async {
    super.onInit();
    await initializeController();
  }

  Future<void> initializeController() async {
    try {
      // Pastikan HomeController sudah diinisialisasi terlebih dahulu
      _homeController = Get.find<HomeController>();
      if (!_homeController.isInitialized) {
        await _homeController.loadUserData();
      }
      
      prefs = await SharedPreferences.getInstance();
      await getRole();
      await fetchLeaders();
      
      // Update canAssess setelah data dimuat
      updateCanAssess();
      
      // Setup listener untuk perubahan role
      ever(_homeController.role, (_) {
        updateCanAssess();
        update(); // Trigger UI update
      });
      
      // Load saved data setelah semua inisialisasi
      loadSavedData();
    } catch (e) {
      print('Error initializing RepairingController: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat memuat data',
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

  void updateCanAssess() {
    try {
      if (_homeController.isInitialized) {
        canAssess.value = _homeController.canAssess;
        print('canAssess updated to: ${canAssess.value}');
      } else {
        print('HomeController not initialized yet');
      }
    } catch (e) {
      print('Error updating canAssess: $e');
      canAssess.value = false;
    }
  }

  Future<void> getRole() async {
    final role = await ApiService().getRoles();
    this.role.value = role;
  }

  Future<void> fetchLeaders() async {
    try {
      final fetchedLeaders = await _andonService.getLeader();
      leaders.assignAll(fetchedLeaders);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch leader data',
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

  void updateLeader(Leader? value) {
    selectedLeader.value = value;
    saveData();
  }

  void updateShift(String? value) {
    selectedShift.value = value;
    saveData();
  }

  void filterLeaders(String query) {
    if (query.isEmpty) {
      filteredLeaders.assignAll(leaders);
    } else {
      filteredLeaders.assignAll(leaders.where((leader) => leader.name.toLowerCase().contains(query.toLowerCase())).toList());
    }
  }

  void addRepairing(int andonId) async {
    if (selectedShift.value == null || selectedLeader.value == null) {
      Get.snackbar(
        'Error', 
        'Please fill all required fields',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
        isDismissible: true,
        overlayBlur: 0,
        overlayColor: Colors.transparent,
      );
      return;
    }

    final repairingData = {
      "shift": selectedShift.value!.toLowerCase(),
      "leader_id": selectedLeader.value!.id,
      "problem": problemController.text,
      "solution": solutionController.text,
      "remarks": remarksController.text,
    };

    try {
      await _andonService.addRepairing(repairingData, andonId);
      saveData();
      Get.snackbar('Success', 'Repairing added successfully',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
      isDismissible: true,
      overlayBlur: 0,
      overlayColor: Colors.transparent,
      );
      Get.offAllNamed('/andon-home');
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Failed to add repairing',
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

  void saveData() {
    prefs.setString('shiftId', selectedShift.value ?? '');
    prefs.setInt('leaderId', selectedLeader.value?.id ?? 0);
    prefs.setString('problem', problemController.text);
    prefs.setString('solution', solutionController.text);
    prefs.setString('remarks', remarksController.text);
  }

  void loadSavedData() {
    selectedShift.value = prefs.getString('shiftId');
    selectedLeader.value = leaders.firstWhereOrNull((l) => l.id == prefs.getInt('leaderId'));
    problemController.text = prefs.getString('problem') ?? '';
    solutionController.text = prefs.getString('solution') ?? '';
    remarksController.text = prefs.getString('remarks') ?? '';
  }

  @override
  void onClose() {
    problemController.dispose();
    solutionController.dispose();
    remarksController.dispose();
    leaderSearchController.dispose();
    super.onClose();
  }
}

