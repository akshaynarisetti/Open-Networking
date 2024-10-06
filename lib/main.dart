import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'screens/home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'models/device_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final showHome = prefs.getBool('showHome') ?? false;
  
  BTDeviceStruct? pairedDevice;
  if (showHome) {
    final deviceJson = prefs.getString('pairedDevice');
    if (deviceJson != null) {
      pairedDevice = BTDeviceStruct.fromJson(json.decode(deviceJson));
    }
  }

  runApp(MyApp(showHome: showHome, pairedDevice: pairedDevice));
}

class MyApp extends StatelessWidget {
  final bool showHome;
  final BTDeviceStruct? pairedDevice;

  const MyApp({Key? key, required this.showHome, this.pairedDevice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Open Networking',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: showHome 
          ? HomeScreen(pairedDevice: pairedDevice)
          : const OnboardingScreen(),
    );
  }
}