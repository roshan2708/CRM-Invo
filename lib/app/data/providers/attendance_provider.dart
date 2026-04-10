import 'package:get/get.dart';
import 'base_provider.dart';
import '../api_constants.dart';

class AttendanceProvider extends BaseProvider {
  // Clock in
  Future<Response> clockIn(double lat, double lng, String timestamp) => post(
        ApiConstants.clockIn,
        {
          'latitude': lat,
          'longitude': lng,
          'timestamp': timestamp,
        },
      );

  // Clock out
  Future<Response> clockOut(double lat, double lng, String timestamp) => put(
        ApiConstants.clockOut,
        {
          'latitude': lat,
          'longitude': lng,
          'timestamp': timestamp,
        },
      );

  // Get current status
  Future<Response> getAttendanceStatus() => get(ApiConstants.attendanceStatus);

  // Get my logs
  Future<Response> getMyLogs() => get(ApiConstants.attendanceLogs);
}
