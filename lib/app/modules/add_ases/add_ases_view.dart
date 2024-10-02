import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'add_ases_controller.dart';

class AddAsesView extends GetView<AddAsesController> {
  const AddAsesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Asesmen'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: controller.areaController,
                decoration: const InputDecoration(labelText: 'Area'),
              ),
              TextField(
                controller: controller.subAreaController,
                decoration: const InputDecoration(labelText: 'Sub Area'),
              ),
              TextField(
                controller: controller.sopNumberController,
                decoration: const InputDecoration(labelText: 'Nomor SOP'),
              ),
              TextField(
                controller: controller.modelController,
                decoration: const InputDecoration(labelText: 'Model'),
              ),
              TextField(
                controller: controller.machineCodeAssetController,
                decoration: const InputDecoration(labelText: 'Kode Aset Mesin'),
              ),
              TextField(
                controller: controller.machineNameController,
                decoration: const InputDecoration(labelText: 'Nama Mesin'),
              ),
              TextField(
                controller: controller.statusController,
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              TextField(
                controller: controller.detailsController,
                decoration: const InputDecoration(labelText: 'Detail'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.addAssessment,
                child: const Text('Tambah Asesmen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
