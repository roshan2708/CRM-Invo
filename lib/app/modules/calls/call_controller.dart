import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/dummy_data.dart';
import '../../data/models/call_log_model.dart';
import '../../data/models/lead_model.dart';

enum RecordingStatus { supported, notSupported, denied }

class CallController extends GetxController {
  // ─── State ────────────────────────────────────────────────────────────────
  final RxList<CallLogModel> _allLogs = <CallLogModel>[].obs;
  final RxList<CallLogModel> filteredLogs = <CallLogModel>[].obs;

  final RxBool isCallActive = false.obs;
  final RxInt callDurationSeconds = 0.obs;
  final Rx<LeadModel?> activeLead = Rx<LeadModel?>(null);
  final Rx<DateTime?> _callStartTime = Rx<DateTime?>(null);

  // Filters
  final RxString searchQuery = ''.obs;
  final Rx<CallType?> filterType = Rx<CallType?>(null);
  final Rx<CallTag?> filterTag = Rx<CallTag?>(null);

  // Recording
  final Rx<RecordingStatus> recordingStatus =
      RecordingStatus.notSupported.obs;

  Timer? _timer;

  // ─── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _allLogs.assignAll(DummyData.callLogs);
    filteredLogs.assignAll(_allLogs);
    ever(searchQuery, (_) => _applyFilters());
    ever(filterType, (_) => _applyFilters());
    ever(filterTag, (_) => _applyFilters());
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  // ─── Filters ──────────────────────────────────────────────────────────────
  void _applyFilters() {
    List<CallLogModel> result = List.from(_allLogs);

    if (filterType.value != null) {
      result = result.where((l) => l.callType == filterType.value).toList();
    }
    if (filterTag.value != null) {
      result = result.where((l) => l.tag == filterTag.value).toList();
    }
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      result = result
          .where(
            (l) =>
                l.clientName.toLowerCase().contains(q) ||
                l.phone.contains(q),
          )
          .toList();
    }

    // Sort newest first
    result.sort((a, b) => b.startTime.compareTo(a.startTime));
    filteredLogs.assignAll(result);
  }

  void setSearch(String q) => searchQuery.value = q;
  void setTypeFilter(CallType? t) => filterType.value = t;
  void setTagFilter(CallTag? t) => filterTag.value = t;
  void clearFilters() {
    searchQuery.value = '';
    filterType.value = null;
    filterTag.value = null;
  }

  // ─── Call Initiation ──────────────────────────────────────────────────────
  Future<void> initiateCall(LeadModel lead) async {
    // Request CALL_PHONE permission
    final status = await Permission.phone.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      Get.snackbar(
        'Permission Required',
        'Phone permission needed. Tap to open Settings.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 5),
        onTap: (_) => openAppSettings(),
      );
      return;
    }

    // Launch native dialer
    final uri = Uri(scheme: 'tel', path: lead.phone.replaceAll(' ', ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar(
        'Cannot Call',
        'Unable to initiate call to ${lead.phone}',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Start tracking
    activeLead.value = lead;
    isCallActive.value = true;
    callDurationSeconds.value = 0;
    _callStartTime.value = DateTime.now();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      callDurationSeconds.value++;
    });
  }

  // ─── End Call ─────────────────────────────────────────────────────────────
  void endCall({String notes = '', CallTag tag = CallTag.none}) {
    _timer?.cancel();
    final lead = activeLead.value;
    if (lead == null) return;

    final endTime = DateTime.now();
    final duration = callDurationSeconds.value;
    final logId = 'c${DateTime.now().millisecondsSinceEpoch}';

    final log = CallLogModel(
      id: logId,
      userId: 'u001', // current user
      clientId: lead.id,
      clientName: lead.name,
      phone: lead.phone,
      callType: duration > 0 ? CallType.outgoing : CallType.missed,
      startTime: _callStartTime.value ?? endTime,
      endTime: endTime,
      durationSeconds: duration,
      notes: notes,
      tag: tag,
    );

    _allLogs.insert(0, log);
    _applyFilters();

    // Reset state
    isCallActive.value = false;
    callDurationSeconds.value = 0;
    activeLead.value = null;
    _callStartTime.value = null;

    Get.snackbar(
      'Call Ended',
      'Duration: ${log.formattedDuration} — saved to call history',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  /// Cancel active call without saving a log entry
  void cancelCall() {
    _timer?.cancel();
    isCallActive.value = false;
    callDurationSeconds.value = 0;
    activeLead.value = null;
    _callStartTime.value = null;
  }

  // ─── Log Management ───────────────────────────────────────────────────────
  void updateLogNotesAndTag(String id, String notes, CallTag tag) {
    final idx = _allLogs.indexWhere((l) => l.id == id);
    if (idx != -1) {
      _allLogs[idx] = _allLogs[idx].copyWith(notes: notes, tag: tag);
      _applyFilters();
    }
  }

  CallLogModel? getLogById(String id) {
    try {
      return _allLogs.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  List<CallLogModel> logsForLead(String leadId) =>
      _allLogs
          .where((l) => l.clientId == leadId)
          .toList()
        ..sort((a, b) => b.startTime.compareTo(a.startTime));

  // ─── Analytics ────────────────────────────────────────────────────────────
  int get totalCalls => _allLogs.length;

  int get todayCallsCount {
    final today = DateTime.now();
    return _allLogs
        .where(
          (l) =>
              l.startTime.year == today.year &&
              l.startTime.month == today.month &&
              l.startTime.day == today.day,
        )
        .length;
  }

  double get avgDurationSeconds {
    final connected =
        _allLogs.where((l) => l.durationSeconds > 0).toList();
    if (connected.isEmpty) return 0;
    final total = connected.fold(0, (sum, l) => sum + l.durationSeconds);
    return total / connected.length;
  }

  String get avgDurationFormatted {
    final secs = avgDurationSeconds.round();
    if (secs == 0) return '0s';
    final m = secs ~/ 60;
    final s = secs % 60;
    if (m == 0) return '${s}s';
    return '${m}m ${s}s';
  }

  int get interestedCount =>
      _allLogs.where((l) => l.tag == CallTag.interested).length;

  int get followUpCount =>
      _allLogs.where((l) => l.tag == CallTag.followUp).length;

  int get notInterestedCount =>
      _allLogs.where((l) => l.tag == CallTag.notInterested).length;

  /// Calls per day for the last 7 days (for bar chart)
  List<MapEntry<DateTime, int>> get callsPerDay {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = DateTime(now.year, now.month, now.day - (6 - i));
      final count = _allLogs
          .where(
            (l) =>
                l.startTime.year == day.year &&
                l.startTime.month == day.month &&
                l.startTime.day == day.day,
          )
          .length;
      return MapEntry(day, count);
    });
  }

  /// Live timer formatted as MM:SS
  String get liveTimerFormatted {
    final m = callDurationSeconds.value ~/ 60;
    final s = callDurationSeconds.value % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // Connected calls count (for dashboard — replaces stub in lead_controller)
  int get connectedCallsCount =>
      _allLogs.where((l) => l.durationSeconds > 0).length;
}
