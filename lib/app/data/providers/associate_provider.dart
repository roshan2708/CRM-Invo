import 'package:get/get.dart';
import 'base_provider.dart';
import '../api_constants.dart';

class AssociateProvider extends BaseProvider {
  // Leads
  Future<Response> fetchMyLeads() => get(ApiConstants.associateMyLeads);
  Future<Response> fetchPerformanceStats(Map<String, dynamic> filters) => get(ApiConstants.associateStats, query: filters.map((k, v) => MapEntry(k, v.toString())));
  Future<Response> updateStatus(String leadId, String status, String note) => put(ApiConstants.updateStatus(leadId), {}, query: {'status': status, 'note': note});
  Future<Response> recordOutcome(String leadId, Map<String, dynamic> outcomeData) => post(ApiConstants.recordOutcome(leadId), outcomeData);
  Future<Response> addLead(Map<String, dynamic> leadData) => post(ApiConstants.associateAddLead, leadData);
  Future<Response> sendPaymentLink(String leadId, Map<String, dynamic> paymentData) => post(ApiConstants.sendPaymentLink(leadId, ''), paymentData); // Default uses no prefix

  // Reports
  Future<Response> fetchTrendData(Map<String, dynamic> filters) => get(ApiConstants.reportsTrend, query: filters.map((k, v) => MapEntry(k, v.toString())));

  // Tasks
  Future<Response> fetchLeadTasks(String leadId) => get(ApiConstants.leadTasks(leadId));
  Future<Response> fetchHierarchicalTasks() => get(ApiConstants.associateTasks); // /tasks
  Future<Response> searchLeadTasksByDate(String leadId, String date) => get('${ApiConstants.associateTasks}/search', query: {'date': date, 'leadId': leadId});
  Future<Response> addLeadTask(String leadId, Map<String, dynamic> task) => post(ApiConstants.leadTasks(leadId), task);
  Future<Response> updateTaskStatus(String taskId, String status) => put(ApiConstants.taskStatus(taskId), {}, query: {'status': status});
}
