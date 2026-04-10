import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../data/dummy_data.dart';
import '../../data/models/lead_model.dart';
import '../auth/auth_controller.dart';
import '../../data/providers/admin_provider.dart';
import '../../data/providers/manager_provider.dart';
import '../../data/providers/tl_provider.dart';
import '../../data/providers/associate_provider.dart';

class LeadController extends GetxController {
  final RxList<LeadModel> _allLeads = <LeadModel>[].obs;
  final RxList<LeadModel> filteredLeads = <LeadModel>[].obs;
  final RxString searchQuery = ''.obs;
  final Rx<LeadStatus?> selectedStatus = Rx<LeadStatus?>(null);
  final RxBool isLoading = false.obs;

  // Calendar state
  final RxBool isCalendarMode = true.obs;
  final Rx<DateTime> focusedCalendarDay = DateTime.now().obs;
  final Rx<DateTime?> selectedCalendarDay = Rx<DateTime?>(null);
  final RxList<LeadModel> leadsForSelectedDay = <LeadModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _allLeads.assignAll(DummyData.leads);
    filteredLeads.assignAll(_allLeads);
    ever(searchQuery, (_) => _applyFilters());
    ever(selectedStatus, (_) => _applyFilters());
    fetchLeadsFromBackend();
  }

  Future<void> fetchLeadsFromBackend() async {
    final auth = Get.find<AuthController>();
    Response? response;
    
    try {
      isLoading.value = true;
      if (auth.isAdmin) {
        response = await Get.find<AdminProvider>().fetchLeads();
      } else if (auth.isManager) {
        response = await Get.find<ManagerProvider>().fetchLeads();
      } else if (auth.isTeamLeader) {
        response = await Get.find<TlProvider>().fetchMyLeads();
      } else {
        response = await Get.find<AssociateProvider>().fetchMyLeads();
      }

      if (response.isOk) {
        final List<dynamic> data = response.body is List ? response.body : (response.body['data'] ?? []);
        if (data.isNotEmpty) {
           final fetchedLeads = data.map((e) => LeadModel.fromJson(e)).toList();
           _allLeads.assignAll(fetchedLeads);
           _applyFilters();
        }
      }
    } catch (e) {
      debugPrint('Error fetching leads from backend: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilters() {
    List<LeadModel> result = List.from(_allLeads);

    if (selectedStatus.value != null) {
      result = result.where((l) => l.status == selectedStatus.value).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      result = result
          .where(
            (l) =>
                l.name.toLowerCase().contains(q) ||
                l.email.toLowerCase().contains(q) ||
                l.phone.contains(q) ||
                (l.company?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }

    filteredLeads.assignAll(result);
  }

  void setSearch(String query) => searchQuery.value = query;

  void setStatusFilter(LeadStatus? status) {
    selectedStatus.value = status;
  }

  void toggleViewMode() {
    isCalendarMode.value = !isCalendarMode.value;
  }

  /// Returns leads whose followUpDate matches a given calendar day
  List<LeadModel> getLeadsForDay(DateTime day) {
    return _allLeads.where((lead) {
      final fud = lead.followUpDate;
      if (fud == null) return false;
      return fud.year == day.year &&
          fud.month == day.month &&
          fud.day == day.day;
    }).toList();
  }

  /// Calendar event loader — returns list of leads for each day (used by table_calendar)
  List<LeadModel> eventLoader(DateTime day) => getLeadsForDay(day);

  void onDaySelected(DateTime selected, DateTime focused) {
    selectedCalendarDay.value = selected;
    focusedCalendarDay.value = focused;
    leadsForSelectedDay.assignAll(getLeadsForDay(selected));
  }

  void clearDaySelection() {
    selectedCalendarDay.value = null;
    leadsForSelectedDay.clear();
  }

  void addLead(LeadModel lead) {
    _allLeads.insert(0, lead);
    _applyFilters();
  }

  void updateLead(LeadModel updated) {
    final idx = _allLeads.indexWhere((l) => l.id == updated.id);
    if (idx != -1) {
      _allLeads[idx] = updated;
      _applyFilters();
      // Refresh selected day if applicable
      final sel = selectedCalendarDay.value;
      if (sel != null) {
        leadsForSelectedDay.assignAll(getLeadsForDay(sel));
      }
    }
  }

  void deleteLead(String id) {
    _allLeads.removeWhere((l) => l.id == id);
    _applyFilters();
    final sel = selectedCalendarDay.value;
    if (sel != null) {
      leadsForSelectedDay.assignAll(getLeadsForDay(sel));
    }
  }

  LeadModel? getLeadById(String id) {
    try {
      return _allLeads.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  void updateLeadStatus(String id, LeadStatus newStatus) {
    final idx = _allLeads.indexWhere((l) => l.id == id);
    if (idx != -1) {
      _allLeads[idx] = _allLeads[idx].copyWith(status: newStatus);
      _applyFilters();
    }
  }

  // ── Dashboard stats ──────────────────────────────────────────────────────────
  int get totalLeads => _allLeads.length;
  int get newLeads =>
      _allLeads.where((l) => l.status == LeadStatus.newLead).length;
  int get convertedLeads =>
      _allLeads.where((l) => l.status == LeadStatus.converted).length;
  int get interestedLeads =>
      _allLeads.where((l) => l.status == LeadStatus.interested).length;
  int get lostLeads =>
      _allLeads.where((l) => l.status == LeadStatus.lost).length;

  double get totalRevenue =>
      _allLeads.fold(0.0, (sum, l) => sum + (l.revenue ?? 0.0));

  double get dailyRevenue {
    final today = DateTime.now();
    return _allLeads.where((l) {
      final date = l.date;
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }).fold(0.0, (sum, l) => sum + (l.revenue ?? 0.0));
  }

  double get monthlyRevenue {
    final today = DateTime.now();
    return _allLeads.where((l) {
      final date = l.date;
      return date.year == today.year && date.month == today.month;
    }).fold(0.0, (sum, l) => sum + (l.revenue ?? 0.0));
  }

  int get todayConnectedCalls =>
      _allLeads.fold(0, (sum, l) => sum + l.connectedCallsCount);

  List<LeadModel> get recentLeads => List.from(_allLeads.take(5));

  /// Number of leads with a followUpDate today
  int get todayFollowUps {
    final today = DateTime.now();
    return _allLeads.where((l) {
      final fud = l.followUpDate;
      if (fud == null) return false;
      return fud.year == today.year &&
          fud.month == today.month &&
          fud.day == today.day;
    }).length;
  }

  /// Leads with followUpDate today (for display)
  List<LeadModel> get todayFollowUpLeads {
    final today = DateTime.now();
    return _allLeads.where((l) {
      final fud = l.followUpDate;
      if (fud == null) return false;
      return fud.year == today.year &&
          fud.month == today.month &&
          fud.day == today.day;
    }).toList();
  }
}
