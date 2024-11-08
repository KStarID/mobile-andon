import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'reviewing_controller.dart';
import '../../../../utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class ReviewingView extends GetView<ReviewingController> {
  const ReviewingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary400, Colors.white],
          ),
        ),
      child:  CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          Obx(() {
            if (controller.repairingCalls.isEmpty) {
              return SliverFillRemaining(
                child: _buildEmptyState(),
              );
            } else {
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final call = controller.repairingCalls[index];
                    return _buildRepairingCard(context, call);
                  },
                  childCount: controller.repairingCalls.length,
                ),
              );
            }
          }),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text('Reviewing List',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primary400, AppColors.primary400],
            ),
          ),
          child: Center(
            child: Icon(Icons.rate_review, size: 80, color: Colors.white),
          ),
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white, size: 32),
        onPressed: () => Get.offAllNamed('/andon-home'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lottie/empty.json',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 24),
          Text(
            'No reviewing list',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary400,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'All reviewing list has been reviewed',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepairingCard(BuildContext context, dynamic call) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text('Andon ID: ${call.id}', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Status: ${call.currentStatus}'),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoItem('PIC', call.pic?.name ?? 'N/A'),
                _buildInfoItem('PIC Role', call.pic?.role.toUpperCase() ?? 'N/A'),
                _buildInfoItem('Area', call.area.name),
                _buildInfoItem('Sub Area', call.subarea.name),
                _buildInfoItem('Model', call.model.name),
                _buildInfoItem('SOP', call.sop.name),
                _buildInfoItem('Start Time', _formatDateTime(call.startTime)),
                _buildInfoItem('Problem', call.problem ?? 'N/A'),
                _buildInfoItem('Solution', call.solution ?? 'N/A'),
                _buildInfoItem('Remarks', call.remarks ?? 'N/A'),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      context: context,
                      andonId: call.id,
                      status: 'approved',
                      label: 'Approve',
                      color: Colors.green,
                      icon: Icons.check_circle,
                    ),
                    _buildActionButton(
                      context: context,
                      andonId: call.id,
                      status: 'rejected',
                      label: 'Reject',
                      color: Colors.red,
                      icon: Icons.cancel,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(': $value')),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required int andonId,
    required String status,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return ElevatedButton.icon(
      onPressed: () => _showConfirmationDialog(context, andonId, status),
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, int andonId, String status) {
    Get.dialog(
      AlertDialog(
        title: Text('Confirmation Review'),
        content: Text('Are you sure you want to ${status == 'approved' ? 'approve' : 'reject'} this repairing?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.reviewRepairing(andonId, status);
              Get.offAllNamed('/andon-home');
            },
            child: Text('Confirm'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary400),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime.toLocal());
  }
}
