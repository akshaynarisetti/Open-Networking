import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/pairing_animation.dart';
import '../../animations/onboarding_connect_animations.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../utils/scan.dart';
import '../home_screen.dart';
import '../../models/device_info.dart';

class OnboardingConnectScreen extends StatefulWidget {
  const OnboardingConnectScreen({Key? key}) : super(key: key);

  @override
  _OnboardingConnectScreenState createState() => _OnboardingConnectScreenState();
}

class _OnboardingConnectScreenState extends State<OnboardingConnectScreen> with SingleTickerProviderStateMixin {
  late OnboardingConnectAnimations animations;
  bool _animationStarted = false;
  bool _isScanning = false;
  bool _isConnected = false;
  BTDeviceStruct? _connectedDevice;

  @override
  void initState() {
    super.initState();
    animations = OnboardingConnectAnimations(this);
    _startScanningAndPairing();
  }

  @override
  void dispose() {
    animations.dispose();
    super.dispose();
  }

  void _startScanningAndPairing() async {
    if (!_isScanning) {
      setState(() {
        _isScanning = true;
      });

      List<BTDeviceStruct?> devices = await scanDevices();
      if (devices.isNotEmpty) {
        await _connectToDevice(devices[0]!);
      } else {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _connectToDevice(BTDeviceStruct device) async {
    try {
      await bleConnectDevice(device.id);
      setState(() {
        _isConnected = true;
        _connectedDevice = device;
      });
      
      await _savePairedDeviceToPreferences(device);
      
      setState(() {
        _animationStarted = true;
      });
      animations.controller.forward();
    } catch (e) {
      print("Failed to connect: $e");
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _savePairedDeviceToPreferences(BTDeviceStruct device) async {
    final prefs = await SharedPreferences.getInstance();
    final deviceJson = jsonEncode({
      'id': device.id,
      'name': device.name,
    });
    await prefs.setString('pairedDevice', deviceJson);
  }

  Future<void> bleConnectDevice(String deviceId, {bool autoConnect = true}) async {
    final device = BluetoothDevice.fromId(deviceId);
    try {
      await device.connect(autoConnect: autoConnect, mtu: null);
      await device.connectionState.where((state) => state == BluetoothConnectionState.connected).first;

      if (Platform.isAndroid) {
        int desiredMtu = 512;
        await device.requestMtu(desiredMtu);
      }
      
    } catch (e) {
      print("Connection error: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 9, 9, 9),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.01),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                            iconSize: 32,
                          ),
                          Expanded(
                            child: Text(
                              'Pair Device',
                              style: GoogleFonts.bricolageGrotesque(
                                fontSize: screenHeight * 0.04,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(width: 48), // To balance the layout
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      AnimatedOpacity(
                        opacity: _isConnected ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 500),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Color.fromARGB(255, 18, 249, 147), width: 2),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: screenHeight * 0.015,
                                height: screenHeight * 0.015,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 18, 249, 147),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Paired',
                                style: GoogleFonts.bricolageGrotesque(
                                  fontSize: screenHeight * 0.022,
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromARGB(255, 18, 249, 147),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            PairingAnimation(animations: animations),
                            SizedBox(height: screenHeight * 0.04),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02),
                              child: Text(
                                _isConnected
                                    ? 'You have Successfully paired your Open Networking Glasses'
                                    : 'Looking for Open Networking Glasses Near By',
                                style: GoogleFonts.bricolageGrotesque(
                                  fontSize: screenHeight * 0.03,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isConnected)
                        Padding(
                          padding: EdgeInsets.only(bottom: screenHeight * 0.05),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => HomeScreen(pairedDevice: _connectedDevice),
                                ),
                              );
                            },
                            child: Text('Continue'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: screenHeight * 0.04,
                                vertical: screenHeight * 0.02,
                              ),
                              textStyle: GoogleFonts.bricolageGrotesque(
                                fontSize: screenHeight * 0.030,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: screenHeight * 0.02),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}