import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'course_model.dart' as individual_course_model;
import 'package:http/http.dart' as https;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'attendance_table_model.dart' as attendance_table_model;

class IndividualCourse extends StatefulWidget {
  final individual_course_model.Course course;
  const IndividualCourse(
      {super.key, required this.course});
  @override
  State<IndividualCourse> createState() => _IndividualCourseState();
}

TableRow buildRow(Map<String, String> rowData) {
  return TableRow(children: [
    Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      child: Text(
        rowData['date']!,
        style: const TextStyle(
          fontSize: 17,
        ),
      ),
    ),
    Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      child: Text(
        rowData['time']!,
        style: const TextStyle(
          fontSize: 17,
        ),
      ),
    ),
    Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      child: Text(
        rowData['status']!,
        style: const TextStyle(
          fontSize: 17,
        ),
      ),
    ),
  ]);
}

class _IndividualCourseState extends State<IndividualCourse> {
  late Future<String?> data;

  Future<attendance_table_model.AttendanceTable?> fetchAttendance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String courseCode = widget.course.courseCode;
    Uri url = Uri.parse(
            'https://curriculum.iitd.ac.in/api/curriculum/courses/student/attendance/')
        .replace(queryParameters: {
      'course_code': courseCode,
      'semester_id': widget.course.semester,
    });

    https.Response response = await https.get(
      url,
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
      },
    );

    print(response.body);

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      attendance_table_model.AttendanceTable attendanceTable =
          attendance_table_model.AttendanceTable.fromJson(
              widget.course, body);
      return attendanceTable;
    } else if (response.statusCode == 401) {
      prefs.remove('access_token');
      prefs.remove('refresh_token');
      prefs.remove('student');
      if (!mounted) return null;
      Navigator.pushReplacementNamed(context, '/');
    } else {
      return null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize:
              const Size.fromHeight(60), // Adjust the height as needed
          child: SafeArea(
            child: Theme(
              data: Theme.of(context).copyWith(
                brightness: Brightness.light, // Change brightness here
              ),
              child: AppBar(
                leading: const BackButton(color: Colors.white),
                title: Text(widget.course.courseCode,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )),
                backgroundColor: const Color.fromARGB(255, 136, 16, 16),
              ),
            ),
          ),
        ),
        body: FutureBuilder<attendance_table_model.AttendanceTable?>(
            future: fetchAttendance(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                print(snapshot.error);
                print(snapshot.stackTrace);
                return Center(child: Text('Error: ${snapshot.stackTrace}'));
              } else if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text('No courses available.'));
              } else {
                attendance_table_model.AttendanceTable attendanceTable =
                    snapshot.data!;
                return SingleChildScrollView(
                  child: Column(children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 5),
                            child: Text(
                              attendanceTable.courseName,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.only(left: 5),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(bottom: 5, top: 5),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                          'lib/assets/icons/location.svg',
                                          height: 19,
                                          width: 19),
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(bottom: 5, top: 5),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                          'lib/assets/icons/calender.svg',
                                          height: 19,
                                          width: 19),
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(bottom: 5, top: 5),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                          'lib/assets/icons/clock.svg',
                                          height: 19,
                                          width: 19),
                                      const SizedBox(width: 10),
                                      const Text(
                                        '10:00 - 11:00',
                                        style: TextStyle(
                                          fontSize: 17,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    attendanceTable.noOfClasses == 0
                                        ? 'No classes scheduled'
                                        : 'Total Classes: ${attendanceTable.noOfClasses}',
                                    style: const TextStyle(
                                      fontSize: 17,
                                    ),
                                  ),
                                  const SizedBox(width: 40),
                                  Text(
                                    attendanceTable.noOfClassesAttended == 0
                                        ? 'No classes attended'
                                        : 'Total Present: ${attendanceTable.noOfClassesAttended}',
                                    style: const TextStyle(
                                      fontSize: 17,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color.fromARGB(255, 250, 221, 221),
                            ),
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(
                                top: 30, left: 20, right: 20),
                            alignment: Alignment.center,
                            child: Text(
                              attendanceTable.noOfClasses == 0
                                  ? 'Attendance = 0%'
                                  : 'Attendance = ${(attendanceTable.noOfClassesAttended / attendanceTable.noOfClasses * 100).toStringAsFixed(2)}%',
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 20),
                        child: Table(
                          border: const TableBorder(
                            horizontalInside: BorderSide(
                              color: Color.fromRGBO(0, 0, 0, 0.15),
                              width: 1,
                            ),
                            bottom: BorderSide(
                              color: Color.fromRGBO(0, 0, 0, 0.15),
                              width: 1,
                            ),
                          ),
                          children: [
                            TableRow(
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 136, 16, 16),
                              ),
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(10),
                                  child: const Text(
                                    'Date',
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(10),
                                  child: const Text(
                                    'Time',
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(10),
                                  child: const Text(
                                    'Status',
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            for (var attendance
                                in attendanceTable.attendanceList)
                              buildRow(attendance)
                          ],
                        )),
                  ]),
                );
              }
            }));
  }
}
