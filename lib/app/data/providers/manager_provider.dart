import 'dart:io';
import 'package:get/get.dart';
import 'base_provider.dart';
import '../api_constants.dart';

class ManagerProvider extends BaseProvider {
  // Dashboard & Reports
  Future<Response> fetchDashboardStats(Map<String, dynamic> filters) => get(ApiConstants.managerDashboardStats, query: filters.map((key, value) => MapEntry(key, value.toString())));
  Future<Response> fetchMemberPerformance(Map<String, dynamic> filters) => get(ApiConstants.managerMemberPerformance, query: filters.map((key, value) => MapEntry(key, value.toString())));
  Future<Response> fetchTrendData(Map<String, dynamic> filters) => get(ApiConstants.reportsTrend, query: filters.map((key, value) => MapEntry(key, value.toString())));
  Future<Response> fetchTeamTree() => get(ApiConstants.managerTeamTree);

  // Users & Hierarchy
  Future<Response> fetchTeamLeaders() => get(ApiConstants.managerTeamLeaders);
  Future<Response> fetchRoles() => get(ApiConstants.managerRoles);
  Future<Response> fetchPermissions() => get(ApiConstants.managerPermissions);
  Future<Response> fetchShifts() => get(ApiConstants.managerShifts);
  Future<Response> createUser(Map<String, dynamic> userData) => post(ApiConstants.managerUsers, userData);
  Future<Response> updateUser(String id, Map<String, dynamic> userData) => put('${ApiConstants.managerUsers}/$id', userData);
  Future<Response> deleteUser(String id) => delete('${ApiConstants.managerUsers}/$id');
  Future<Response> assignSupervisor(String associateId, String supervisorId) => post('${ApiConstants.managerUsers}/$associateId/assign-supervisor/$supervisorId', {});

  // Leads
  Future<Response> fetchLeads() => get(ApiConstants.managerLeads);
  Future<Response> addLead(Map<String, dynamic> leadData) => post(ApiConstants.managerLeads, leadData);
  Future<Response> assignLead(String leadId, String tlId) => post('${ApiConstants.managerAssignLead}/$leadId/$tlId', {});
  Future<Response> bulkAssignLeads(List<String> leadIds, String tlId) => post(ApiConstants.managerBulkAssignLeads, {'leadIds': leadIds, 'tlId': tlId});
  Future<Response> recordCallOutcome(String leadId, Map<String, dynamic> data) => post(ApiConstants.recordOutcome(leadId), data);

  Future<Response> bulkUploadLeads(File file, String? assignedToIds) {
    final Map<String, dynamic> formMap = {
      'file': MultipartFile(file, filename: 'leads.csv'),
    };
    if (assignedToIds != null) formMap['assignedToIds'] = assignedToIds;
    return post(ApiConstants.managerBulkUploadLeads, FormData(formMap));
  }
}
