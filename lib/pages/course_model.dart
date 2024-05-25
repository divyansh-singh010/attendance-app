// course_model.dart
class Course {
  final String courseCode;
  final String courseName;
  final int numberOfClasses;
  final String semester;

  Course({
    required this.courseCode,
    required this.courseName,
    required this.numberOfClasses,
    required this.semester,
  });

  static Course fromJson(Map<String, dynamic> json, String semester) {
    return Course(
      courseCode: json['course_code'],
      courseName: json['course_name'],
      numberOfClasses: json['number_of_classes'],
      semester: semester,
    );
  }
}

class Semester {
  final String academicYear;
  final int semesterNumber;
  final String semesterId;

  Semester({
    required this.academicYear,
    required this.semesterNumber,
    required this.semesterId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Semester &&
          runtimeType == other.runtimeType &&
          academicYear == other.academicYear &&
          semesterNumber == other.semesterNumber &&
          semesterId == other.semesterId;

  @override
  int get hashCode =>
      academicYear.hashCode ^
      semesterNumber.hashCode ^
      semesterId.hashCode;

  static Semester fromJson(Map<String, dynamic> json) {
    return Semester(
      academicYear: json['academic_year'],
      semesterNumber: json['semester_number'],
      semesterId: json['semester_id'].toString(),
    );
  }
}
