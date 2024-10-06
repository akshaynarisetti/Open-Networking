import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import '../models/device_info.dart';

Future<List<BTDeviceStruct>> scanDevices() async {
  List<BTDeviceStruct> foundDevices = [];
  bool deviceFound = false;
  
  while (!deviceFound) {
    foundDevices = await bleFindDevices();
    var filteredDevices = foundDevices.where((device) => device.name == "OpenVision").toList();
    
    if (filteredDevices.isNotEmpty) {
      deviceFound = true;
      return filteredDevices;
    }
    // Wait for a 1 second interval before scanning again
    await Future.delayed(const Duration(seconds: 1));
  }
  
  return []; // This line should never be reached, but it's here to satisfy the return type
}


Future<List<BTDeviceStruct>> bleFindDevices() async {
  List<BTDeviceStruct> devices = [];
  StreamSubscription<List<ScanResult>>? scanSubscription;

  try {
    if ((await FlutterBluePlus.isSupported) == false) return [];

    // Start scanning if not already scanning
    if (!FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 5),
        withServices: [Guid("19b10000-e8f2-537e-4f6c-d104768a1214")], // Add specific service UUIDs if needed
      );
    }

    // Listen to scan results
    scanSubscription = FlutterBluePlus.scanResults.listen(
      (results) {
        List<ScanResult> scannedDevices = results.where((r) => r.device.platformName.isNotEmpty).toList();
        scannedDevices.sort((a, b) => b.rssi.compareTo(a.rssi));

        devices = scannedDevices.map((deviceResult) {
          return BTDeviceStruct(
            name: deviceResult.device.platformName,
            id: deviceResult.device.remoteId.str,
            rssi: deviceResult.rssi,
          );
        }).toList();
      },
      onError: (e) {
        print('bleFindDevices error: $e');
      },
    );

    // Wait for the scan to complete
    await Future.delayed(const Duration(seconds: 5));

    // Stop scanning
    await FlutterBluePlus.stopScan();
  } finally {
    // Cancel subscription to avoid memory leaks
    await scanSubscription?.cancel();
  }
  return devices;
}