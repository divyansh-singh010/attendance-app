// attendance_table_model.dart
import 'package:attendance_client_app/pages/course_model.dart';

class AttendanceTable {
  final String courseCode;
  final String courseName;
  final String semester;
  final List<Map<String, String>> attendanceList;
  final int noOfClasses;
  final int noOfClassesAttended;

  AttendanceTable({
    required this.courseCode,
    required this.courseName,
    required this.semester,
    required this.attendanceList,
    required this.noOfClasses,
    required this.noOfClassesAttended,
  });

  static AttendanceTable fromJson(
      Course course, Map<String, dynamic> json) {
    return AttendanceTable(
      courseCode: course.courseCode,
      courseName: course.courseName,
      semester: "$json['semester']['academic_year'] ${json['semester']['semester_number'].toString()}",
      attendanceList:
          (json['attendance'] as List).map<Map<String, String>>((item) {
        return {
          'date': item['date'],
          'time': item['time'],
          'status': 'P',
        };
      }).toList(),
      noOfClasses: json['total_classes'],
      noOfClassesAttended: json['present_count'],
    );
  }
}
