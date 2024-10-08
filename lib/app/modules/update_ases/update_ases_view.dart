import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import '../../data/models/assessment_model.dart';
import 'update_ases_controller.dart';

class UpdateAsesView extends GetView<UpdateAsesController> {
  const UpdateAsesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Assessment'),
        centerTitle: true,
        backgroundColor: AppColors.primary100,
      ),
      body: Obx(() {
        if (controller.assessment.value == null) {
          return Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedShift.value,
                  onChanged: controller.updateShift,
                  items: controller.shifts.map((shift) => DropdownMenuItem(value: shift, child: Text(shift))).toList(),
                  decoration: InputDecoration(labelText: 'Shift'),
                )),
                TextFormField(
                  controller: controller.sopNumberController,
                  decoration: InputDecoration(labelText: 'SOP Number'),
                ),
                Obx(() => DropdownButtonFormField<SubArea>(
                  value: controller.selectedSubArea.value,
                  onChanged: controller.updateSubArea,
                  items: controller.subAreas.map((subArea) => DropdownMenuItem(value: subArea, child: Text(subArea.name))).toList(),
                  decoration: InputDecoration(labelText: 'Sub Area'),
                )),
                Obx(() => DropdownButtonFormField<Model>(
                  value: controller.selectedModel.value,
                  onChanged: controller.updateModel,
                  items: controller.models.map((model) => DropdownMenuItem(value: model, child: Text(model.name))).toList(),
                  decoration: InputDecoration(labelText: 'Model'),
                )),
                TextFormField(
                  controller: controller.machineCodeAssetController,
                  decoration: InputDecoration(labelText: 'Machine Code Asset'),
                  readOnly: true,
                ),
                Obx(() => DropdownButtonFormField<String>(
                  value: controller.machineStatus.value,
                  onChanged: controller.updateMachineStatus,
                  items: controller.machineStatusOptions.map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
                  decoration: InputDecoration(labelText: 'Machine Status'),
                )),
                TextFormField(
                  controller: controller.detailsController,
                  decoration: InputDecoration(labelText: 'Notes'),
                  maxLines: 3,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => controller.updateAssessment(),
                  child: const Text('Update Assessment'),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
