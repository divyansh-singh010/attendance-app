import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:pointycastle/asymmetric/api.dart' as pc;
import 'package:http/http.dart' as https;
import 'package:qr_scanner_plus/qr_scanner_plus.dart';
import 'package:google_mlkit_barcode_scanning/src/barcode_scanner.dart';

class QRCODE extends StatefulWidget {
  const QRCODE({super.key});

  @override
  State<QRCODE> createState() => _QRCODEState();
}

class _QRCODEState extends State<QRCODE> {
  late Future<String?> data;
  int secondsRemaining = 15;
  bool enableResend = false;
  late Timer timer;

  void markAttendance(String qrCode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String udid = await FlutterUdid.consistentUdid;
    String? student = prefs.getString('student');
    Map<String, dynamic>? studentMap =
        student != null ? jsonDecode(student) : null;
    String? kerberos = studentMap != null ? studentMap['kerberosID'] : "";
    final splitString = qrCode.split('#');
    final publicKeyString = splitString[0];
    final courseCode = splitString[1];
    final semesterId = splitString[2];

    final publicKey =
        enc.RSAKeyParser().parse(publicKeyString) as pc.RSAPublicKey;
    final encrypter = enc.Encrypter(
        enc.RSA(publicKey: publicKey, encoding: enc.RSAEncoding.OAEP));
    final encrypted = encrypter.encrypt('$udid#$kerberos').base16;
    final accessToken = prefs.getString('access_token');
    https.Response response = await https.post(
      Uri.parse(
          'https://curriculum.iitd.ac.in/api/attendance/attendance/mark/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(<String, String>{
        'encrypted_text': encrypted,
        'course_code': courseCode,
        'semester_id': semesterId,
      }),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Attendance Marked: ${body['message']}'),
          duration: const Duration(seconds: 5),
        ),
      );
    } else {
      final Map<String, dynamic> body = jsonDecode(response.body);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${body['message']}'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: SafeArea(
          child: Container(
            color: const Color.fromARGB(255, 153, 35, 35),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: const Text(
              'QR Code',
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
        height: double.infinity,
        margin: const EdgeInsets.only(
          top: 20,
          bottom: 20,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 4,
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
                      child:
                          // MobileScanner(
                          //   controller: MobileScannerController(
                          //     detectionSpeed: DetectionSpeed.unrestricted,
                          //     torchEnabled: false,
                          //     facing: CameraFacing.back,
                          //     detectionTimeoutMs: 2000,
                          //   ),
                          //   onDetect: (capture) {
                          //     final List<Barcode> barcodes = capture.barcodes;
                          //     if (barcodes.isNotEmpty &&
                          //         barcodes.first.rawValue != null) {
                          //       // disable the scanner
                          //       // registerDevice(barcodes.first.rawValue.toString());
                          //       markAttendance(barcodes.first.rawValue.toString());
                          //     }
                          //   },
                          // ),                  ),
                          // implerment the logic of the above qr code scanner code with the qr_scanner_plus package
                          // the above code is not working properly
                          // the below code is the implementation of the qr_scanner_plus package
                          QrScannerPlusView(
                        _onResult,
                        debug: true,
                      )),
                ),
              ),
            ),
            const Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text(
                  'Scan QR Code To Mark Attendance',
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

  _onResult(List<Barcode> barcodes) {
    for (final barcode in barcodes) {
      print(barcode.type);
      print(barcode.rawValue);
    }
  }

  @override
  dispose() {
    timer.cancel();
    super.dispose();
  }
}
