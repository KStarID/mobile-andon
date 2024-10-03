import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'detail_history_controller.dart';

class DetailHistoryView extends GetView<DetailHistoryController> {
  const DetailHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Assessment'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailSection(),
              SizedBox(height: 24),
              Text(
                'Riwayat Perubahan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              _buildHistoryList(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDetailSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('No', controller.assessment.value.no.toString()),
            _buildDetailItem('Shift', controller.assessment.value.shift),
            _buildDetailItem('Area', controller.assessment.value.area),
            _buildDetailItem('Sub Area', controller.assessment.value.subArea),
            _buildDetailItem('Nomor SOP', controller.assessment.value.sopNumber),
            _buildDetailItem('Model', controller.assessment.value.model),
            _buildDetailItem('Kode Aset Mesin', controller.assessment.value.machineCodeAsset),
            _buildDetailItem('Nama Mesin', controller.assessment.value.machineName),
            _buildDetailItem('Status', controller.assessment.value.status),
            _buildDetailItem('Detail', controller.assessment.value.details),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value ?? 'N/A'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: controller.historyList.length,
      itemBuilder: (context, index) {
        final history = controller.historyList[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Perubahan #${index + 1}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                _buildHistoryItem('Submitted by', history.submittedBy),
                _buildHistoryItem('Updated Time', history.updatedTime),
                _buildHistoryItem('Sub Area', history.subArea),
                _buildHistoryItem('Status', history.status),
                _buildHistoryItem('Remark', history.remark),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value ?? 'N/A'),
          ),
        ],
      ),
    );
  }
}
