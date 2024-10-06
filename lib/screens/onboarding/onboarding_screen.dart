import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'onboarding_pairing.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finishOnboarding(BuildContext context) async {
    bool permissionsAccepted = false;
    if (Platform.isIOS) {
      PermissionStatus bleStatus = await Permission.bluetooth.request();
      debugPrint('bleStatus: $bleStatus');
      permissionsAccepted = bleStatus.isGranted;
    } else {
      PermissionStatus bleScanStatus = await Permission.bluetoothScan.request();
      PermissionStatus bleConnectStatus = await Permission.bluetoothConnect.request();
      permissionsAccepted =
          bleConnectStatus.isGranted && bleScanStatus.isGranted;
      debugPrint('bleScanStatus: $bleScanStatus ~ bleConnectStatus: $bleConnectStatus');
    }
    if (!permissionsAccepted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text(
              'Permissions Required',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'This app needs Bluetooth and Location permissions to function properly. Please enable them in the settings.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const OnboardingConnectScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 375;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 9, 9, 9),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: screenSize.height * 0.03),
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.05,
                  vertical: screenSize.height * 0.01,
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Shimmer.fromColors(
                        direction: ShimmerDirection.ltr,
                        baseColor: Color.fromARGB(255, 198, 244, 50),
                        highlightColor: Color.fromARGB(255, 232, 255, 156),
                        period: Duration(milliseconds: 1000),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 198, 244, 50),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.03,
                        vertical: screenSize.height * 0.005,
                      ),
                      child: Text(
                        'Open Networking',
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: isSmallScreen ? 15 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _animation.value),
                  child: child,
                );
              },
              child: Image.asset(
                'assets/images/glasses.png',
                width: double.infinity,
                height: screenSize.height * 0.4,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: screenSize.height * 0.1),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: isSmallScreen ? 32 : 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(text: 'Your vision with '),
                    WidgetSpan(
                      child: Text(
                        'superpowers',
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: isSmallScreen ? 32 : 40,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 198, 244, 50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.only(bottom: screenSize.height * 0.05),
              child: ElevatedButton(
                onPressed: () => _finishOnboarding(context),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.1,
                    vertical: screenSize.height * 0.01,
                  ),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: Text(
                  'Get Started',
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: isSmallScreen ? 25 : 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}