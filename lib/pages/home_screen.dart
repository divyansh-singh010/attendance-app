import 'package:flutter/material.dart';
import 'e_id.dart';
import 'qr_code.dart';
import 'courses.dart';
import 'package:attendance_client_app/components/bottom_nav_component.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  int currentIndex = 0;
    
  @override
  void initState() {
    super.initState();
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return const EID(); // Use EidScreen widget
      case 1:
        return const QRCODE(); // Use QrCodeScreen widget
      case 2:
        return const Courses(); // Use CoursesScreen widget
      default:
        return const EID(); // Use EidScreen widget
    }
  }

  void setIndex(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  int getIndex() {
    return currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getScreen(currentIndex),
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationComponent(
              currentIndex: 0,
              label: 'e-ID',
              iconPath: 'id',
              setIndex: setIndex,
              getIndex: getIndex),
          NavigationComponent(
              currentIndex: 1,
              label: 'QR',
              iconPath: 'qr',
              setIndex: setIndex,
              getIndex: getIndex),
          NavigationComponent(
              currentIndex: 2,
              label: 'Courses',
              iconPath: 'courses',
              setIndex: setIndex,
              getIndex: getIndex),
        ],
        selectedIndex: currentIndex,
        backgroundColor: Colors.white,
        elevation: 2,
        height: 72,
      ),
    );
  }
}
