import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as https;
import 'package:flutter_udid/flutter_udid.dart';

class RegisterDevice extends StatefulWidget {
  const RegisterDevice({super.key, required this.title});

  final String title;

  @override
  State<RegisterDevice> createState() => _RegisterDevice();
}

class _RegisterDevice extends State<RegisterDevice> {
  void registerDevice(String qrCode) async {
    print("Registering Device with QR Code: $qrCode");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String udid = await FlutterUdid.consistentUdid;
    print("Device UDID: $udid");
    // Make a post request to the server to register the device
    // The server will return a token
    // Save the token to shared preferences
    https.Response response = await https.post(
      Uri.parse('https://curriculum.iitd.ac.in/api/user/device/register/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String, String>{
        'qr_text': qrCode,
        'udid': udid,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      print("Access Token: ${body['tokens']['access']}");
      prefs.setString('access_token', body['tokens']['access']);
      prefs.setString('refresh_token', body['tokens']['refresh']);
      prefs.setString('student', jsonEncode(body['student']));
      print(prefs.getString('access_token'));
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      final Map<String, dynamic> body = jsonDecode(response.body);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid QR Code: ${body['message']}'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: SafeArea(
          child: Container(
            color: const Color.fromARGB(255, 153, 35, 35),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: const Text(
              'Register Device',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(
          top: 100,
          bottom: 40,
        ),
        padding: const EdgeInsets.all(60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 153, 35, 35),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: MobileScanner(
                      controller: MobileScannerController(
                        detectionSpeed: DetectionSpeed.normal,
                        torchEnabled: false,
                        facing: CameraFacing.back,
                        detectionTimeoutMs: 2000,
                      ),
                      onDetect: (capture) {
                        final List<Barcode> barcodes = capture.barcodes;
                        if (barcodes.isNotEmpty &&
                            barcodes.first.rawValue != null) {
                          // disable the scanner
                          registerDevice(barcodes.first.rawValue.toString());
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            const Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(top: 100),
                child: Text(
                  'Scan QR Code To Register your Device',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
