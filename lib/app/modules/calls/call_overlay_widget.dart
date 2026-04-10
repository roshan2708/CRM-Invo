import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../data/models/call_log_model.dart';
import 'call_controller.dart';

/// Floating in-call overlay shown while a call is active.
/// Displayed as a bottom sheet-style widget.
class CallOverlayWidget extends StatefulWidget {
  const CallOverlayWidget({super.key});

  @override
  State<CallOverlayWidget> createState() => _CallOverlayWidgetState();
}

class _CallOverlayWidgetState extends State<CallOverlayWidget>
    with SingleTickerProviderStateMixin {
  final _notesCtrl = TextEditingController();
  CallTag _selectedTag = CallTag.none;
  bool _isReceived = false;
  CallOutcome _selectedOutcome = CallOutcome.none;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _showEndCallSheet(CallController ctrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            margin: const EdgeInsets.all(16),
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('End Call Feedback', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                
                // Was the call received
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Call Received?', style: Theme.of(context).textTheme.bodyMedium),
                    Switch(
                      value: _isReceived,
                      onChanged: (val) => setSheetState(() => _isReceived = val),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Outcome selector
                Text('Outcome:', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<CallOutcome>(
                      value: _selectedOutcome,
                      isExpanded: true,
                      onChanged: (val) {
                        if (val != null) setSheetState(() => _selectedOutcome = val);
                      },
                      items: CallOutcome.values.map((o) {
                        return DropdownMenuItem(value: o, child: Text(o.label));
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tag selector
                Text('Tag this call:', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: CallTag.values.map((tag) {
                    final selected = _selectedTag == tag;
                    Color tagColor = _tagColor(tag);
                    return GestureDetector(
                      onTap: () => setSheetState(() => _selectedTag = tag),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? tagColor.withValues(alpha: 0.15)
                              : Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected ? tagColor : Theme.of(context).dividerColor,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          tag.label,
                          style: TextStyle(
                            color: selected
                                ? tagColor
                                : Theme.of(context).textTheme.bodySmall?.color,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                // Notes field
                TextField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Add call notes (optional)...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Get.back();
                          ctrl.cancelCall();
                        },
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: AppColors.white,
                        ),
                        onPressed: () {
                          Get.back();
                          ctrl.endCall(
                            notes: _notesCtrl.text.trim(),
                            tag: _selectedTag,
                            isReceived: _isReceived,
                            outcome: _selectedOutcome,
                          );
                        },
                        child: const Text('Save & End'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _tagColor(CallTag tag) {
    switch (tag) {
      case CallTag.interested:
        return AppColors.success;
      case CallTag.followUp:
        return const Color(0xFFF59E0B);
      case CallTag.notInterested:
        return AppColors.error;
      case CallTag.none:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CallController>();
    final theme = Theme.of(context);

    return Obx(() {
      if (!ctrl.isCallActive.value) return const SizedBox.shrink();

      final lead = ctrl.activeLead.value;
      if (lead == null) return const SizedBox.shrink();

      return Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, _) => Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(
                            alpha: _pulse.value,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Active Call',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.7),
                        letterSpacing: 1.2,
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    // Recording not supported badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.mic_off_rounded,
                            size: 12,
                            color: AppColors.white.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Recording N/A',
                            style: TextStyle(
                              color: AppColors.white.withValues(alpha: 0.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Avatar + Name
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.avatarColors[
                        lead.avatarIndex % AppColors.avatarColors.length],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    lead.name.split(' ').take(2).map((e) => e[0]).join(),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  lead.name,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (lead.company != null)
                  Text(
                    lead.company!,
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  lead.phone,
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                // Live Timer
                Obx(
                  () => Text(
                    ctrl.liveTimerFormatted,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 4,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // End Call Button
                GestureDetector(
                  onTap: () => _showEndCallSheet(ctrl),
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.error.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.call_end_rounded,
                      color: AppColors.white,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'End Call',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
