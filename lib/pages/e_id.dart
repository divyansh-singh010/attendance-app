import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EID extends StatefulWidget {
  const EID({super.key});

  @override
  State<EID> createState() => _EIDState();
}

class _EIDState extends State<EID> {
  late Future<Map<String, dynamic>> data;

  @override
  void initState() {
    super.initState();
    data = getStudentDetails();
  }

  Future<Map<String, dynamic>> getStudentDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? student = prefs.getString('student');
    if (student != null && student.isNotEmpty) {
      return Future.value(Map<String, dynamic>.from(jsonDecode(student)));
    } else {
      return Future.value({});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize:
              const Size.fromHeight(60.0), // Adjust the height as needed
          child: SafeArea(
            child: Container(
              color: const Color.fromARGB(
                  255, 153, 35, 35), // Background color of the title
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Text(
                'E-ID',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        body: FutureBuilder<Map<String, dynamic>>(
            future: data,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('No data'));
              } else {
                Map<String, dynamic> student = snapshot.data!;
                return SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                      Image.asset('lib/assets/icons/home.png',
                          height: 200, width: double.infinity),
                      Text(
                        student['name'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 40, left: 20, right: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(7),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'lib/assets/icons/persons.svg',
                                    height: 30,
                                    width: 30,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    student['entryNumber'],
                                    style: const TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(7),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'lib/assets/icons/hat.svg',
                                    height: 30,
                                    width: 30,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    student['category'] ?? 'B.Tech',
                                    style: const TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(7),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'lib/assets/icons/building.svg',
                                    height: 30,
                                    width: 30,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Department of ${student['department'].toString().toUpperCase()}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]));
              }
            }));
  }
}
