import 'dart:io';
import 'package:get/get.dart';
import '../api_constants.dart';

class LeadProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = ApiConstants.baseUrl;
    super.onInit();
  }

  // Get lead details
  Future<Response> getLead(String id) => get(ApiConstants.leadDetail(id));

  // Get lead stats
  Future<Response> getLeadStats() => get(ApiConstants.leadStats);

  // Update lead status
  Future<Response> updateLeadStatus(String id, String status, String note) =>
      put(
        '${ApiConstants.updateStatus(id)}?status=$status&note=$note',
        {},
      );

  // Record call outcome
  Future<Response> recordLeadOutcome(
          String id, Map<String, dynamic> outcomeData) =>
      post(
        ApiConstants.recordOutcome(id),
        outcomeData,
      );

  // Upload call recording
  Future<Response> uploadCallRecording(
    String id,
    File file,
    int duration,
    String timestamp,
  ) {
    final form = FormData({
      'file': MultipartFile(file, filename: 'recording.m4a'),
      'duration': duration,
      'timestamp': timestamp,
    });
    return post(ApiConstants.uploadRecording(id), form);
  }
}
