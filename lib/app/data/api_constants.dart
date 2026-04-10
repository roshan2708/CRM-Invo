class ApiConstants {
  static const String baseUrl = 'http://13.127.111.89/api';

  // Auth
  static const String login = '/auth/login';

  // Universal reporting endpoints
  static const String reportsTrend = '/reports/trend';

  // Admin Endpoints
  static const String adminDashboardStats = '/admin/dashboard/stats';
  static const String adminMemberPerformance = '/admin/reports/member-performance';
  static const String adminUsers = '/admin/users';
  static const String adminPermissions = '/admin/permissions';
  static const String adminShifts = '/admin/shifts';
  static const String adminAssociates = '/admin/associates'; // + /id
  static const String adminTeamLeaders = '/admin/team-leaders';
  static const String adminLeads = '/admin/leads';
  static const String adminTeamTree = '/admin/team-tree';
  static const String adminAssignLead = '/admin/assign-lead'; // + /leadId/tlId
  static const String adminBulkAssignLeads = '/admin/leads/bulk-assign';
  
  static const String adminCallLogs = '/call-records/admin/all';
  static const String adminGlobalCallStats = '/call-records/admin/stats';
  static const String adminCallBulkUpload = '/call-records/bulk-upload';

  // Manager Endpoints
  static const String managerDashboardStats = '/manager/dashboard/stats';
  static const String managerMemberPerformance = '/manager/reports/member-performance';
  static const String managerTeamTree = '/manager/team-tree';
  static const String managerLeads = '/manager/leads';
  static const String managerTeamLeaders = '/manager/team-leaders';
  static const String managerRoles = '/manager/roles';
  static const String managerPermissions = '/manager/permissions';
  static const String managerShifts = '/manager/shifts';
  static const String managerUsers = '/manager/users';
  static const String managerAssignLead = '/manager/assign-lead';
  static const String managerBulkAssignLeads = '/manager/leads/bulk-assign';
  static const String managerBulkUploadLeads = '/manager/leads/bulk-upload';

  // Team Leader Endpoints
  static const String tlMyLeads = '/tl/leads/my';
  static const String tlDashboardStats = '/tl/dashboard/stats';
  static const String tlMemberPerformance = '/tl/reports/member-performance';
  static const String tlSubordinates = '/tl/subordinates';
  static const String tlLeads = '/tl/leads';
  static const String tlBulkUploadLeads = '/tl/leads/bulk-upload';

  // Associate Endpoints
  static const String associateMyLeads = '/leads/my';
  static const String associateStats = '/leads/stats';
  static const String associateAddLead = '/leads';
  static const String associateTasks = '/tasks';

  // Shared Lead Paths
  static String leadDetail(String id) => '/leads/$id';
  static String recordOutcome(String id) => '/leads/$id/record-outcome';
  static String uploadRecording(String id) => '/leads/$id/upload-recording';
  static String updateStatus(String id) => '/leads/$id/status';
  static String sendPaymentLink(String id, String prefix) => '$prefix/leads/$id/send-payment-link';

  // Tasks
  static String leadTasks(String id) => '/tasks/lead/$id';
  static String taskStatus(String id) => '/tasks/$id/status';

  // Payments
  static const String manualPaymentRecord = '/payments/manual-record';
  static String updatePaymentStatus(String id) => '/payments/$id/status';
  static String splitPayment(String id) => '/payments/$id/split';
  static String invoiceByLead(String id) => '/payments/lead/$id/invoice';
  
  static String paymentHistoryAdmin = '/admin/payments/history';
  static String paymentHistoryManager = '/manager/payments/history';
  static String paymentHistoryTl = '/tl/payments/history';

  // Attendance Endpoints
  static const String clockIn = '/attendance/clock-in';
  static const String clockOut = '/attendance/clock-out';
  static const String attendanceStatus = '/attendance/status';
  static const String attendanceLogs = '/attendance/my-logs';
  static const String adminOffices = '/admin/attendance/offices';
  static const String adminPolicies = '/admin/attendance/policies';
  static const String adminAttendanceShifts = '/admin/attendance/shifts';

  // Call Records
  static const String uploadCallRecord = '/call-records/upload';
}
