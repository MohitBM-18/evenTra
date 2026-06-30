import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/booking_model.dart';
import '../theme/app_theme.dart';

class ApprovalTimeline extends StatelessWidget {
  final List<ApprovalRecord> history;

  const ApprovalTimeline({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Text(
        'No approval history yet.',
        style: GoogleFonts.inter(
          color: AppTheme.secondaryTextColor(context),
          fontStyle: FontStyle.italic,
          fontSize: 13,
        ),
      );
    }

    // Sort by timestamp descending
    final sortedHistory = List<ApprovalRecord>.from(history)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedHistory.length,
      itemBuilder: (context, index) {
        final record = sortedHistory[index];
        final isLast = index == sortedHistory.length - 1;
        final isFirst = index == 0;

        Color statusColor;
        IconData statusIcon;

        switch (record.action) {
          case 'approved':
          case 'force_approved':
            statusColor = AppTheme.success;
            statusIcon = Icons.check_circle_rounded;
            break;
          case 'rejected':
          case 'force_rejected':
            statusColor = AppTheme.error;
            statusIcon = Icons.cancel_rounded;
            break;
          case 'changes_requested':
            statusColor = AppTheme.warning;
            statusIcon = Icons.edit_note_rounded;
            break;
          default:
            statusColor = AppTheme.info;
            statusIcon = Icons.info_rounded;
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timeline line and circle
              Column(
                children: [
                  Container(
                    width: 2,
                    height: 16,
                    color: isFirst ? Colors.transparent : AppTheme.borderColor(context),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: statusColor),
                    ),
                    child: Icon(statusIcon, size: 14, color: statusColor),
                  ),
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isLast ? Colors.transparent : AppTheme.borderColor(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0, top: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            record.approverName,
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          Text(
                            DateFormat('MMM d, y • h:mm a').format(record.timestamp),
                            style: GoogleFonts.inter(
                              color: AppTheme.secondaryTextColor(context),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${record.approverRole} • ${_formatAction(record.action)}',
                        style: GoogleFonts.inter(
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      if (record.comment.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.bgColor(context),
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(color: AppTheme.borderColor(context)),
                          ),
                          child: Text(
                            record.comment,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppTheme.textColor(context),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatAction(String action) {
    switch (action) {
      case 'approved':
        return 'Approved';
      case 'force_approved':
        return 'Force Approved';
      case 'rejected':
        return 'Rejected';
      case 'force_rejected':
        return 'Force Rejected';
      case 'changes_requested':
        return 'Requested Changes';
      default:
        return action;
    }
  }
}
