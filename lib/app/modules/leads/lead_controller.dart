import 'package:get/get.dart';
import '../../data/dummy_data.dart';
import '../../data/models/lead_model.dart';

class LeadController extends GetxController {
  final RxList<LeadModel> _allLeads = <LeadModel>[].obs;
  final RxList<LeadModel> filteredLeads = <LeadModel>[].obs;
  final RxString searchQuery = ''.obs;
  final Rx<LeadStatus?> selectedStatus = Rx<LeadStatus?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _allLeads.assignAll(DummyData.leads);
    filteredLeads.assignAll(_allLeads);
    ever(searchQuery, (_) => _applyFilters());
    ever(selectedStatus, (_) => _applyFilters());
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

  void addLead(LeadModel lead) {
    _allLeads.insert(0, lead);
    _applyFilters();
  }

  void updateLead(LeadModel updated) {
    final idx = _allLeads.indexWhere((l) => l.id == updated.id);
    if (idx != -1) {
      _allLeads[idx] = updated;
      _applyFilters();
    }
  }

  void deleteLead(String id) {
    _allLeads.removeWhere((l) => l.id == id);
    _applyFilters();
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

  // Dashboard stats
  int get totalLeads => _allLeads.length;
  int get newLeads =>
      _allLeads.where((l) => l.status == LeadStatus.newLead).length;
  int get convertedLeads =>
      _allLeads.where((l) => l.status == LeadStatus.converted).length;
  int get interestedLeads =>
      _allLeads.where((l) => l.status == LeadStatus.interested).length;

  double get totalRevenue =>
      _allLeads.fold(0.0, (sum, l) => sum + (l.revenue ?? 0.0));

  int get todayConnectedCalls =>
      _allLeads.fold(0, (sum, l) => sum + l.connectedCallsCount);

  List<LeadModel> get recentLeads => List.from(_allLeads.take(5));
}
