import 'dart:io';
import 'package:get/get.dart';
import 'base_provider.dart';
import '../api_constants.dart';

class TlProvider extends BaseProvider {
  // Leads
  Future<Response> fetchMyLeads() => get(ApiConstants.tlMyLeads);
  Future<Response> addLead(Map<String, dynamic> leadData) => post(ApiConstants.tlLeads, leadData);
  Future<Response> updateLeadStatus(String leadId, String status, String note) => put(ApiConstants.updateStatus(leadId), {}, query: {'status': status, 'note': note});
  Future<Response> recordCallOutcome(String leadId, Map<String, dynamic> outcomeData) => post(ApiConstants.recordOutcome(leadId), outcomeData);
  Future<Response> assignLead(String leadId, String associateId) => post('${ApiConstants.tlLeads}/$leadId/assign/$associateId', {});
  Future<Response> sendPaymentLink(String leadId, Map<String, dynamic> paymentData) => post(ApiConstants.sendPaymentLink(leadId, '/tl'), paymentData);

  // Dashboard & Reports
  Future<Response> fetchDashboardStats(Map<String, dynamic> filters) => get(ApiConstants.tlDashboardStats, query: filters.map((k, v) => MapEntry(k, v.toString())));
  Future<Response> fetchMemberPerformance(Map<String, dynamic> filters) => get(ApiConstants.tlMemberPerformance, query: filters.map((k, v) => MapEntry(k, v.toString())));
  Future<Response> fetchTrendData(Map<String, dynamic> filters) => get(ApiConstants.reportsTrend, query: filters.map((k, v) => MapEntry(k, v.toString())));

  // Subordinates
  Future<Response> fetchSubordinates() => get(ApiConstants.tlSubordinates);

  // Tasks
  Future<Response> createTask(Map<String, dynamic> taskData) => post(ApiConstants.associateTasks, taskData); // Both use /tasks for creation typically, mapped from TL service

  Future<Response> bulkUploadLeads(File file, String? assignedToIds) {
    final Map<String, dynamic> formMap = {
      'file': MultipartFile(file, filename: 'leads.csv'),
    };
    if (assignedToIds != null) formMap['assignedToIds'] = assignedToIds;
    return post(ApiConstants.tlBulkUploadLeads, FormData(formMap));
  }
}
