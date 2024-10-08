import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import '../../data/models/assessment_model.dart';
import 'add_ases_controller.dart';

class AddAsesView extends GetView<AddAsesController> {
  const AddAsesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Assessment'),
        centerTitle: true,
        backgroundColor: AppColors.primary100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Obx(() => DropdownButtonFormField<String>(
                value: controller.selectedShift.value,
                decoration: const InputDecoration(labelText: 'Shift'),
                items: controller.shifts.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: controller.updateShift,
              )),

              Obx(() => DropdownButtonFormField<SubArea>(
                value: controller.selectedSubArea.value,
                decoration: const InputDecoration(labelText: 'Sub Area'),
                items: controller.subAreas.map((SubArea subArea) {
                  return DropdownMenuItem<SubArea>(
                    value: subArea,
                    child: Text('${subArea.name} '),
                  );
                }).toList(),
                onChanged: controller.updateSubArea,
              )),

              Obx(() => DropdownButtonFormField<Model>(
                value: controller.selectedModel.value,
                decoration: const InputDecoration(labelText: 'Model'),
                items: controller.models.map((Model model) {
                  return DropdownMenuItem<Model>(
                    value: model,
                    child: Text(model.name),
                  );
                }).toList(),
                onChanged: controller.updateModel,
              )),

              TextField(
                controller: controller.sopNumberController,
                decoration: const InputDecoration(labelText: 'SOP Number'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.machineCodeAssetController,
                      decoration: const InputDecoration(labelText: 'Machine Code Asset'),
                      onEditingComplete: controller.fetchMachineDetails,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.qr_code_scanner),
                    onPressed: controller.scanQRCode,
                  ),
                ],
              ),
              Obx(() => TextField(
                controller: TextEditingController(text: controller.machineName.value),
                decoration: const InputDecoration(labelText: 'Machine Name'),
                enabled: false,
              )),
              Obx(() => DropdownButtonFormField<String>(
                value: controller.machineStatus.value,
                decoration: const InputDecoration(labelText: 'Machine Status'),
                items: controller.machineStatusOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: controller.updateMachineStatus,
                hint: Text('Select machine status'),
              )),
              TextField(
                controller: controller.detailsController,
                decoration: const InputDecoration(labelText: 'Remarks'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: controller.addAssessment,
                    child: const Text('Add Assessment'),
                  ),
                  ElevatedButton(
                    onPressed: controller.clearForm,
                    child: const Text('Clear Form'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}