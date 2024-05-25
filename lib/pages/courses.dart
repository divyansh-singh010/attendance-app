import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'individual_courses.dart';
import 'course_model.dart' as course_model;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Courses extends StatefulWidget {
  const Courses({super.key});

  @override
  State<Courses> createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {
  late Future<List<course_model.Course>?> data = fetchCourses('');
  late String selectedSemester = '1';

  Future<List<course_model.Semester>?> fetchSemesters() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');

    Uri url =
        Uri.parse('https://curriculum.iitd.ac.in/api/curriculum/semesters/');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $accessToken',
    });
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      List<course_model.Semester> semesters = [];
      for (var semester in body['semesters']) {
        semesters.add(course_model.Semester.fromJson(semester));
      }
      return semesters;
    } else if (response.statusCode == 401) {
      prefs.remove('access_token');
      prefs.remove('refresh_token');
      prefs.remove('student');
      if (!mounted) return null;
      Navigator.pushReplacementNamed(context, '/');
    } else {
      print('Error: ${response.statusCode}');
      return null;
    }
    return null;
  }

  Future<List<course_model.Course>?> fetchCourses(semesterId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');

    if (semesterId == '' || semesterId == null) {
      Uri semesterUrl = Uri.parse(
          'https://curriculum.iitd.ac.in/api/curriculum/semester/current/');
      final semesterResponse = await http.get(semesterUrl, headers: {
        'Authorization': 'Bearer $accessToken',
      });
      if (semesterResponse.statusCode == 200) {
        final Map<String, dynamic> semesterBody =
            jsonDecode(semesterResponse.body);
        semesterId = semesterBody['semester_id'].toString();
      } else {
        print('Error: ${semesterResponse.statusCode}');
        return null;
      }
    }

    Uri url = Uri.parse(
        'https://curriculum.iitd.ac.in/api/curriculum/courses/student/?semester_id=$semesterId');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $accessToken',
    });
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      List<course_model.Course> courses = [];
      for (var course in body['courses']) {
        courses.add(course_model.Course.fromJson(course, semesterId));
      }
      return courses;
    } else if (response.statusCode == 401) {
      prefs.remove('access_token');
      prefs.remove('refresh_token');
      prefs.remove('student');
      if (!mounted) return null;
      Navigator.pushReplacementNamed(context, '/');
    } else {
      print('Error: ${response.statusCode}');
      return null;
    }
    return null;
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
                'Courses',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 20, left: 20),
                  child: const Text(
                    'Semesters',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20, right: 20),
                  child: FutureBuilder<List<course_model.Semester>?>(
                    future: fetchSemesters(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text('No semesters available.'));
                      } else {
                        List<course_model.Semester> semesters = snapshot.data!;
                        return DropdownButton<String>(
                          value: selectedSemester.isNotEmpty ? selectedSemester : semesters[0].semesterId,
                          onChanged: (String? semester) {
                            // Handle the change in semester, fetch courses for the selected semester, etc.
                            setState(() {
                              selectedSemester = semester!;
                              data = fetchCourses(semester);
                            });
                          },
                          menuMaxHeight: semesters.length * 50.0,
                          items: semesters
                              .map<DropdownMenuItem<String>>((semester) {
                            return DropdownMenuItem<String>(
                              value: semester.semesterId,
                              child: Text(
                                '${semester.academicYear} - ${semester.semesterNumber}',
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            FutureBuilder<List<course_model.Course>?>(
              future: data,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No courses available.'));
                } else {
                  List<course_model.Course> courses = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      course_model.Course course = courses[index];
                      return InkWell(
                        onTap: () {
                          // Handle the tap on a course, navigate to the individual course page, etc.
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      IndividualCourse(course: course)));
                        },
                        child: Container(
                          margin: const EdgeInsets.only(
                              top: 30, left: 20, right: 20),
                          padding: const EdgeInsets.only(
                              top: 15, left: 20, right: 20, bottom: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color.fromARGB(255, 250, 221, 221),
                          ),
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                course.courseCode,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                course.courseName,
                                style: const TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(
                                        'lib/assets/icons/location.svg',
                                        height: 24,
                                        width: 24),
                                    const SizedBox(width: 10),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ));
  }
}
