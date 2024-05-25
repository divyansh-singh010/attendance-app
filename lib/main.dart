import 'package:flutter/material.dart';
import 'package:attendance_client_app/pages/register_device.dart';
import 'package:attendance_client_app/pages/home_screen.dart';
import 'package:attendance_client_app/pages/splash_screen.dart';
import 'dart:io';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:flutter/services.dart';

void main() {
  HttpOverrides.global = DevHttpOverrides();
  runApp(const MyApp());
}

class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> secureScreen() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    secureScreen();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance Nexus',
      theme: ThemeData(
        textTheme: const TextTheme(
          bodySmall: TextStyle(
            fontFamily: 'Manrope',
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Manrope',
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Manrope',
          ),
          headlineSmall: TextStyle(
            fontFamily: 'Manrope',
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Manrope',
          ),
          headlineLarge: TextStyle(
            fontFamily: 'Manrope',
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 153, 35, 35),
          primary: const Color.fromARGB(255, 153, 35, 35),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(title: 'Attendance Nexus'),
      initialRoute: '/',
      routes: {
        '/home': (context) => const HomeScreen(
              title: 'Attendance Nexus',
            ),
        '/register': (context) =>
            const RegisterDevice(title: 'Attendance Nexus'),
      },
    );
  }
}
