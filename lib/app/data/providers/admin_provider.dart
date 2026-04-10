import 'dart:io';
import 'package:get/get.dart';
import 'base_provider.dart';
import '../api_constants.dart';

class AdminProvider extends BaseProvider {
  // Dashboard & Reports
  Future<Response> fetchDashboardStats(Map<String, dynamic> filters) => get(ApiConstants.adminDashboardStats, query: filters.map((key, value) => MapEntry(key, value.toString())));
  Future<Response> fetchMemberPerformance(Map<String, dynamic> filters) => get(ApiConstants.adminMemberPerformance, query: filters.map((key, value) => MapEntry(key, value.toString())));
  Future<Response> fetchTrendData(Map<String, dynamic> filters) => get(ApiConstants.reportsTrend, query: filters.map((key, value) => MapEntry(key, value.toString())));

  // Users
  Future<Response> fetchUsers() => get(ApiConstants.adminUsers);
  Future<Response> createUser(Map<String, dynamic> userData) => post(ApiConstants.adminUsers, userData);
  Future<Response> updateUser(String id, Map<String, dynamic> userData) => put('${ApiConstants.adminUsers}/$id', userData);
  Future<Response> deleteUser(String id) => delete('${ApiConstants.adminUsers}/$id');

  // Hierarchy
  Future<Response> fetchAssociatesByTl(String tlId) => get('${ApiConstants.adminAssociates}/$tlId');
  Future<Response> fetchTeamLeaders() => get(ApiConstants.adminTeamLeaders);
  Future<Response> fetchTeamTree() => get(ApiConstants.adminTeamTree);

  // Leads
  Future<Response> fetchLeads() => get(ApiConstants.adminLeads);
  Future<Response> assignLead(String leadId, String tlId) => post('${ApiConstants.adminAssignLead}/$leadId/$tlId', {});
  Future<Response> bulkAssignLeads(List<String> leadIds, String tlId) => post(ApiConstants.adminBulkAssignLeads, {'leadIds': leadIds, 'tlId': tlId});

  // Access
  Future<Response> fetchPermissions() => get(ApiConstants.adminPermissions);

  // Call Records Audit
  Future<Response> fetchCallLogsAdmin(Map<String, dynamic> filters) => get(ApiConstants.adminCallLogs, query: filters.map((key, value) => MapEntry(key, value.toString())));
  Future<Response> fetchGlobalCallStats() => get(ApiConstants.adminGlobalCallStats);
  
  Future<Response> bulkUploadCallLogs(File file) {
    final form = FormData({
      'file': MultipartFile(file, filename: 'call_logs.csv'),
    });
    return post(ApiConstants.adminCallBulkUpload, form);
  }

  Future<Response> uploadCallRecord(Map<String, dynamic> payload, File file) {
    final form = FormData({
      'file': MultipartFile(file, filename: 'call.m4a'),
      if (payload['leadId'] != null) 'leadId': payload['leadId'],
      'phoneNumber': payload['phoneNumber'],
      'callType': payload['callType'] ?? 'OUTGOING',
      'status': payload['status'] ?? 'CONNECTED',
      if (payload['note'] != null) 'note': payload['note'],
      'duration': payload['duration'] ?? 0,
    });
    return post(ApiConstants.uploadCallRecord, form);
  }

  // Attendance
  Future<Response> fetchOffices() => get(ApiConstants.adminOffices);
  Future<Response> createOffice(Map<String, dynamic> data) => post(ApiConstants.adminOffices, data);
  Future<Response> updateOffice(String id, Map<String, dynamic> data) => put('${ApiConstants.adminOffices}/$id', data);
  Future<Response> deleteOffice(String id) => delete('${ApiConstants.adminOffices}/$id');

  Future<Response> fetchPolicies() => get(ApiConstants.adminPolicies);
  Future<Response> createPolicy(Map<String, dynamic> data) => post(ApiConstants.adminPolicies, data);
  Future<Response> updatePolicy(String id, Map<String, dynamic> data) => put('${ApiConstants.adminPolicies}/$id', data);
  Future<Response> deletePolicy(String id) => delete('${ApiConstants.adminPolicies}/$id');

  Future<Response> fetchShifts() => get(ApiConstants.adminAttendanceShifts);
  Future<Response> createShift(Map<String, dynamic> data) => post(ApiConstants.adminAttendanceShifts, data);
  Future<Response> updateShift(String id, Map<String, dynamic> data) => put('${ApiConstants.adminAttendanceShifts}/$id', data);
  Future<Response> deleteShift(String id) => delete('${ApiConstants.adminAttendanceShifts}/$id');
}
