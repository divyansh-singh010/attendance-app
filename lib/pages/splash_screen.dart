import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendance_client_app/pages/register_device.dart';
import 'package:attendance_client_app/pages/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.title});

  final String title;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _loadingPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _checkTokenAndNavigate();
  }

  void _checkTokenAndNavigate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    // Simulating loading progress
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 20));

      if (!mounted) return;

      setState(() {
        _loadingPercentage = i / 100.0;
      });
    }

    print("Token: $token");

    if (token != null && token.isNotEmpty) {
      _navigateToHomeScreen();
    } else {
      _navigateToRegisterDevice();
    }
  }

  void _navigateToHomeScreen() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(title: widget.title),
        ),
      );
    }
  }

  void _navigateToRegisterDevice() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterDevice(title: widget.title),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      SvgPicture.asset('lib/assets/icons/bg.svg', fit: BoxFit.cover),
      Container(
        margin: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'lib/assets/icons/iitd_logo.svg',
                      height: 80,
                      width: 80,
                    ),
                    const SizedBox(width: 30),
                    const Text(
                      'IITD Attendance App',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      // textAlign: TextAlign.center,
                    )
                  ]),
            ),
            LinearProgressIndicator(
              value: _loadingPercentage,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Loading: ${(_loadingPercentage * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    ]));
  }
}
