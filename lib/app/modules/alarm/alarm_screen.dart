import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alarm/alarm.dart';
import 'package:vibration/vibration.dart';
import '../../../utils/app_colors.dart';

class AlarmScreen extends StatefulWidget {
  final AlarmSettings alarmSettings;

  const AlarmScreen({super.key, required this.alarmSettings});

  @override
  // ignore: library_private_types_in_public_api
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {

  @override
  void initState() {
    super.initState();
    _startVibration();
  }

  void _startVibration() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [500, 1000, 500, 2000], repeat: -1);
    }
  }

  void _stopVibration() {
    if (mounted) {
      Vibration.cancel();
      setState(() {
      });
    }
  }

  void _stopAlarm() {
    Alarm.stop(widget.alarmSettings.id);
    _stopVibration();
    if (mounted) {
      Get.back();
    }
  }


  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primary400, Colors.white],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 200,
                    color: Colors.red,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Andon System Alert!',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${widget.alarmSettings.notificationSettings.body} Andon System need Attention!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      _stopAlarm();
                      Get.offAllNamed('/andon-home');
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    ),
                    child: Text('Stop Call', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    Vibration.cancel();
    super.dispose();
  }
}
