import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_app_bar.dart';
import '../../routes/app_routes.dart';
import 'call_controller.dart';
import '../../data/models/call_log_model.dart';

class CallDetailView extends StatefulWidget {
  const CallDetailView({super.key});

  @override
  State<CallDetailView> createState() => _CallDetailViewState();
}

class _CallDetailViewState extends State<CallDetailView> {
  late TextEditingController _notesCtrl;
  late CallTag _tag;
  bool _editingNotes = false;

  @override
  void initState() {
    super.initState();
    final logId = Get.arguments as String;
    final ctrl = Get.find<CallController>();
    final log = ctrl.getLogById(logId);
    _notesCtrl = TextEditingController(text: log?.notes ?? '');
    _tag = log?.tag ?? CallTag.none;
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
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

  Color _callTypeColor(CallType t) {
    switch (t) {
      case CallType.outgoing:
        return AppColors.success;
      case CallType.missed:
        return AppColors.error;
      case CallType.failed:
        return const Color(0xFFF59E0B);
    }
  }

  IconData _callTypeIcon(CallType t) {
    switch (t) {
      case CallType.outgoing:
        return Icons.call_made_rounded;
      case CallType.missed:
        return Icons.call_missed_rounded;
      case CallType.failed:
        return Icons.call_end_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final logId = Get.arguments as String;
    final ctrl = Get.find<CallController>();
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Obx(() {
      final log = ctrl.getLogById(logId);
      if (log == null) {
        return Scaffold(
          appBar: CustomAppBar(title: 'Call Detail'),
          body: const Center(child: Text('Call not found')),
        );
      }

      final typeColor = _callTypeColor(log.callType);

      return Scaffold(
        appBar: CustomAppBar(
          title: 'Call Detail',
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_note_rounded),
              onPressed: () => setState(() => _editingNotes = !_editingNotes),
              tooltip: 'Edit notes',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(size.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(size.width * 0.05),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_callTypeIcon(log.callType), color: typeColor, size: 32),
                    ),
                    const SizedBox(height: 12),
                    Text(log.clientName, style: theme.textTheme.headlineLarge),
                    const SizedBox(height: 4),
                    Text(log.phone, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    // Type badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        log.callType.label,
                        style: TextStyle(
                          color: typeColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Duration big display
                    Text(
                      log.formattedDuration,
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                        letterSpacing: -1,
                      ),
                    ),
                    Text('Duration', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              SizedBox(height: size.width * 0.04),

              // Timestamps
              _SectionCard(
                title: 'Call Info',
                children: [
                  _InfoRow(
                    icon: Icons.play_arrow_rounded,
                    label: 'Started',
                    value: DateFormat('dd MMM yyyy, hh:mm a').format(log.startTime),
                  ),
                  if (log.endTime != null)
                    _InfoRow(
                      icon: Icons.stop_rounded,
                      label: 'Ended',
                      value: DateFormat('dd MMM yyyy, hh:mm a').format(log.endTime!),
                    ),
                  _InfoRow(
                    icon: Icons.timer_outlined,
                    label: 'Duration',
                    value: log.formattedDuration,
                  ),
                ],
              ),
              SizedBox(height: size.width * 0.03),

              // Tag selector
              _SectionCard(
                title: 'Call Tag',
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: CallTag.values.map((tag) {
                      final selected = _tag == tag;
                      final tc = _tagColor(tag);
                      return GestureDetector(
                        onTap: () {
                          setState(() => _tag = tag);
                          ctrl.updateLogNotesAndTag(
                            log.id,
                            _notesCtrl.text.trim(),
                            tag,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? tc.withValues(alpha: 0.12)
                                : theme.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected ? tc : theme.dividerColor,
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            tag.label,
                            style: TextStyle(
                              color: selected
                                  ? tc
                                  : theme.textTheme.bodySmall?.color,
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
                ],
              ),
              SizedBox(height: size.width * 0.03),

              // Recording section
              _SectionCard(
                title: 'Recording',
                children: [
                  if (log.recordingPath != null)
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.snackbar(
                          'Playback',
                          'Audio player coming soon.',
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                        );
                      },
                      icon: const Icon(Icons.play_circle_outline_rounded),
                      label: const Text('Play Recording'),
                    )
                  else
                    Container(
                      padding: EdgeInsets.all(size.width * 0.03),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.mic_off_rounded,
                            size: 18,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Recording not available — blocked by Android 10+ privacy restrictions or device not supported.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(height: size.width * 0.03),

              // Notes
              _SectionCard(
                title: 'Notes',
                trailing: TextButton.icon(
                  onPressed: () {
                    if (_editingNotes) {
                      ctrl.updateLogNotesAndTag(
                        log.id,
                        _notesCtrl.text.trim(),
                        _tag,
                      );
                      Get.snackbar(
                        'Saved',
                        'Notes updated.',
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(16),
                        borderRadius: 12,
                        duration: const Duration(seconds: 2),
                      );
                    }
                    setState(() => _editingNotes = !_editingNotes);
                  },
                  icon: Icon(
                    _editingNotes ? Icons.check_rounded : Icons.edit_outlined,
                    size: 16,
                  ),
                  label: Text(_editingNotes ? 'Save' : 'Edit'),
                ),
                children: [
                  _editingNotes
                      ? TextField(
                          controller: _notesCtrl,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Enter call notes...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                      : Text(
                          log.notes.isEmpty
                              ? 'No notes added.'
                              : log.notes,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                            color: log.notes.isEmpty
                                ? theme.textTheme.bodySmall?.color
                                : null,
                            fontStyle: log.notes.isEmpty
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                        ),
                ],
              ),
              SizedBox(height: size.width * 0.04),

              // Call Again button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.until((r) => r.settings.name == AppRoutes.leadDetail ||
                        r.settings.name == AppRoutes.leads);
                  },
                  icon: const Icon(Icons.call_rounded),
                  label: const Text('Return & Call Again'),
                ),
              ),
              SizedBox(height: size.height * 0.04),
            ],
          ),
        ),
      );
    });
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: theme.textTheme.headlineSmall),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
