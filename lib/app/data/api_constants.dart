class ApiConstants {
  static const String baseUrl = 'https://api.crmapp.com/api';

  // Auth
  static const String login = '/auth/login';

  // Leads
  static const String leads = '/leads';
  static String leadDetail(String id) => '/leads/$id';
  static String recordOutcome(String id) => '/leads/$id/record-outcome';
  static String uploadRecording(String id) => '/leads/$id/upload-recording';
  static String updateStatus(String id) => '/leads/$id/status';
  static const String leadStats = '/leads/stats';

  // Attendance
  static const String clockIn = '/attendance/clock-in';
  static const String clockOut = '/attendance/clock-out';
  static const String attendanceStatus = '/attendance/status';
  static const String attendanceLogs = '/attendance/my-logs';
}
