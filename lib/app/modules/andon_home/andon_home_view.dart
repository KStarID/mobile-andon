import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../../utils/app_colors.dart';
import '../../data/models/andon_model.dart';
import '../../services/service.dart';
import '../home/home_controller.dart';
import 'andon_home_controller.dart';

class AndonHomeView extends GetView<AndonHomeController> {
  AndonHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Andon System', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Colors.white
          )
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary400,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white, size: 30),
            onPressed: () {
              Get.find<AuthService>().logout();
              Get.offAllNamed('/splash-screen');
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary400, AppColors.primary100],
          ),
        ),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary400),
            ));
          } else if (controller.andonCalls.isEmpty && controller.messages.isEmpty) {
            return _buildNoCallsView();
          } else {
            return _buildAndonCallsView();
          }
        }),
      ),
      floatingActionButton: _buildFloatingActionButtons(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildAndonCallsView() {
    final activeCalls = controller.andonCalls.where((call) => 
      call.currentStatus == 'calling' || call.currentStatus == 'repairing'
    ).toList();

    // Mengurutkan panggilan berdasarkan waktu terbaru
    activeCalls.sort((a, b) => b.startTime.compareTo(a.startTime));

    final callingCalls = activeCalls.where((call) => call.currentStatus == 'calling').toList();
    final repairingCalls = activeCalls.where((call) => call.currentStatus == 'repairing').toList();

    return ListView(
      children: [
        if (callingCalls.isNotEmpty) ...[
          _buildSectionHeader('Calling'),
          ...callingCalls.map((call) => _buildAndonCallCard(call, false)),
        ],
        if (repairingCalls.isNotEmpty) ...[
          _buildSectionHeader('Repairing'),
          ...repairingCalls.map((call) => _buildAndonCallCard(call, true)),
        ],
        if (activeCalls.isEmpty) _buildNoCallsView(),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        title,
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildAndonCallCard(AndonCall call, bool isRepairing) {
    final Color cardColor = isRepairing ? Colors.orange[100]! : Colors.red[100]!;
    final Color statusColor = isRepairing ? Colors.orange : Colors.red;
    final String statusText = isRepairing ? 'Repairing' : 'Calling';

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            title: Text(
              'Area: ${call.area.name}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            leading: CircleAvatar(
              backgroundColor: statusColor,
              radius: 30,
              child: Icon(isRepairing ? Icons.build : Icons.warning, color: Colors.white, size: 30),
            ),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                statusText,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Sub Area', call.subarea.name),
                _buildInfoRow('Model', call.model.name),
                _buildInfoRow('SOP', call.sop.name),
                _buildInfoRow('Date', _formatDate(call.startTime)),
                if (call.pic != null) _buildInfoRow('PIC', call.pic!.name),
              ],
            ),
          ),
          if (isRepairing) ...[
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.table_chart, color: Colors.white),
              label: Text('Back to Repairing', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary400,
              ),
              onPressed: () => Get.offAllNamed('/repairing', arguments: {
                'andonId': call.id,
              }),
            ),
            SizedBox(height: 10),
          ],
          if (!isRepairing) ...[
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.qr_code_scanner, color: Colors.white),
              label: Text('Scan QR', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary400,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: EdgeInsets.symmetric(horizontal: 35, vertical: 10),
              ),
              onPressed: () => _handleScan(call),
            ),
            SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          Text(
            ': $value',
            style: TextStyle(fontSize: 18, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    
    final jakarta = tz.getLocation('Asia/Jakarta');
    final wibDateTime = tz.TZDateTime.from(date, jakarta);
    return DateFormat('dd MMM yyyy, HH:mm').format(wibDateTime);
  }

  void _handleScan(AndonCall call) async {
    final result = await Get.toNamed('/qr-scan', arguments: false);
    if (result != null) {
      await controller.processQRScanResult(result, call);
      await Future.delayed(Duration(seconds: 20));
    }
  }

  Widget _buildNoCallsView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary400, AppColors.primary100],
        ),
      ),
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 24),
          padding: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                spreadRadius: 5,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary100.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  size: 80,
                  color: AppColors.primary400,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'All Systems Normal',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary400,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'No active Andon calls at the moment.\nEverything is running smoothly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Get.offAllNamed('/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary400,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.dashboard, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Back to Dashboard',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Obx(() {
      final homeController = Get.find<HomeController>();
      final bool canReview = homeController.canReview;
      if (canReview) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'review',
              onPressed: () => Get.toNamed('/reviewing'),
              backgroundColor: AppColors.primary400,
              elevation: 4,
              child: const Icon(Icons.reviews, size: 28),
            ),
            SizedBox(height: 16),
            FloatingActionButton(
              heroTag: 'finish',
              onPressed: () => Get.offAllNamed('/andon-history'),
              backgroundColor: AppColors.primary400,
              elevation: 4,
              child: const Icon(Icons.history, size: 28),
            ),
            SizedBox(height: 16),
          ],
        );
      } else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'history',
              onPressed: () => Get.offAllNamed('/andon-history'),
              backgroundColor: AppColors.primary400,
              elevation: 4,
              child: const Icon(Icons.history, size: 28),
            ),
            SizedBox(height: 16),
          ],
        );
      }
    });
  }

  Widget _buildBottomNavigationBar() {
    return Obx(() {
      Get.put(HomeController());
      final bool canViewAssessment = Get.find<HomeController>().canViewAssessment;
      final List<BottomNavigationBarItem> items = [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        if (canViewAssessment)
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_suggest),
            label: 'Machinery',
          ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notification_important),
          label: 'Andon System',
        ),
      ];

      int currentIndex = canViewAssessment ? 2 : 1;

      return BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: AppColors.primary400,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 14,
        unselectedFontSize: 14,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: items,
        onTap: (index) {
          if (index == 0) {
            Get.offAllNamed('/home');
          } else if (canViewAssessment && index == 1) {
            Get.offAllNamed('/asesment');
          } else if (index == (canViewAssessment ? 2 : 1)) {
          }
        },
      );
    });
  }
}
