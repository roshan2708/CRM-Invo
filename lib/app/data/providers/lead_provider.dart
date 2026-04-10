import 'dart:io';
import 'package:get/get.dart';
import 'base_provider.dart';
import '../api_constants.dart';

class LeadProvider extends BaseProvider {
  // Get lead details
  Future<Response> getLead(String id) => get(ApiConstants.leadDetail(id));

  // Get lead stats
  Future<Response> getLeadStats() => get(ApiConstants.associateStats);

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
