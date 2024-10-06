import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/device_info.dart';

class HomeScreen extends StatefulWidget {
  final BTDeviceStruct? pairedDevice;

  const HomeScreen({Key? key, this.pairedDevice}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Uint8List> imageDataList = [];
  bool isReceivingImage = false;
  bool isLoading = false;
  late BTDeviceStruct? connectedDevice;

  @override
  void initState() {
    super.initState();
    connectedDevice = widget.pairedDevice;
    if (connectedDevice != null) {
      _startReceivingImages();
    }
  }

  Future<void> _startReceivingImages() async {
    await receiveImage(connectedDevice!);
  }

  Future<void> receiveImage(BTDeviceStruct BTDeviceStruct) async {
    final device = BluetoothDevice.fromId(BTDeviceStruct.id);

    final services = await device.discoverServices();

    for (BluetoothService service in services) {
      if (service.uuid.toString() == '19b10000-e8f2-537e-4f6c-d104768a1214') {
        List<BluetoothCharacteristic> characteristics = service.characteristics;
        for (BluetoothCharacteristic characteristic in characteristics) {
          if (characteristic.uuid.toString() == '19b10005-e8f2-537e-4f6c-d104768a1214') {
            await characteristic.setNotifyValue(true);

            List<int> receivedData = [];

            characteristic.value.listen((value) {
              if (value[0] == 0xFF && value[1] == 0xFF) {
                // End of image transmission
                setState(() {
                  imageDataList.add(Uint8List.fromList(receivedData));
                  isReceivingImage = false;
                });
                receivedData.clear();
              } else {
                if (!isReceivingImage) {
                  isReceivingImage = true;
                  receivedData.clear();
                }
                receivedData.addAll(value.sublist(2));
              }
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Open Networking'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      connectedDevice != null
                          ? 'Connected to ${connectedDevice!.name}'
                          : 'Not Connected',
                      style: TextStyle(fontSize: 18),
                    ),
                    if (isReceivingImage) CircularProgressIndicator(),
                  ],
                ),
              ),
              Expanded(
                child: imageDataList.isEmpty
                    ? Center(
                        child: Text(
                          'No images received yet',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : GridView.builder(
                        padding: EdgeInsets.all(8),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        itemCount: imageDataList.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  imageDataList[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _onSearchImage(imageDataList[index]);
                                  },
                                  child: Text('Search'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
          if (isLoading)
            Center(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  void _onSearchImage(Uint8List image) async {
    setState(() {
      isLoading = true;
    });

    // Convert image to Base64
    String base64Image = base64Encode(image);

    // Define the API URL
    String apiUrl = 'https://networking-agents.onrender.com/search_face';

    // Create the request body
    Map<String, dynamic> requestBody = {
      'image_base64': base64Image,
    };

    // Send the image to the API
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Parse the response
        final responseData = jsonDecode(response.body);
        final String aiResponse = responseData['ai_response'];
        _showResultsModal(context, aiResponse);
      } else {
        print('Search failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred during search: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showResultsModal(BuildContext context, String aiResponse) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('AI Response'),
          content: Text(aiResponse),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
