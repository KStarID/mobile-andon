import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../data/models/assessment_model.dart';
import '../asesment/asesment_controller.dart';

class AddAsesController extends GetxController {
  final shiftController = TextEditingController();
  final areaController = TextEditingController();
  final subAreaController = TextEditingController();
  final sopNumberController = TextEditingController();
  final modelController = TextEditingController();
  final machineCodeAssetController = TextEditingController();
  final machineNameController = TextEditingController();
  final statusController = TextEditingController();
  final detailsController = TextEditingController();

  void addAssessment() {
    if (shiftController.text.isNotEmpty &&
        areaController.text.isNotEmpty &&
        subAreaController.text.isNotEmpty &&
        sopNumberController.text.isNotEmpty &&
        modelController.text.isNotEmpty &&
        machineCodeAssetController.text.isNotEmpty &&
        machineNameController.text.isNotEmpty &&
        statusController.text.isNotEmpty &&
        detailsController.text.isNotEmpty) {
      final newAssessment = Assessment(
        no: Get.find<AsesmentController>().assessments.length + 1,
        updatedTime: DateTime.now().toString(),
        shift: shiftController.text,
        area: areaController.text,
        subArea: subAreaController.text,
        sopNumber: sopNumberController.text,
        model: modelController.text,
        machineCodeAsset: machineCodeAssetController.text,
        machineName: machineNameController.text,
        status: statusController.text,
        details: detailsController.text,
      );

      // Simpan asesmen baru ke dalam list di AssessmentController
      Get.find<AsesmentController>().addAssessment(newAssessment);

      // Bersihkan form
      shiftController.clear();
      areaController.clear();
      subAreaController.clear();
      sopNumberController.clear();
      modelController.clear();
      machineCodeAssetController.clear();
      machineNameController.clear();
      statusController.clear();
      detailsController.clear();

      // Kembali ke halaman asesmen
      Get.back();
    } else {
      Get.snackbar('Error', 'Semua field harus diisi');
    }
  }

  @override
  void onClose() {
    shiftController.dispose();
    areaController.dispose();
    subAreaController.dispose();
    sopNumberController.dispose();
    modelController.dispose();
    machineCodeAssetController.dispose();
    machineNameController.dispose();
    statusController.dispose();
    detailsController.dispose();
    super.onClose();
  }
}
