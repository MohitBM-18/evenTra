import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/enums.dart';

class StatusChip extends StatelessWidget {
  final BookingStatus status;
  final double fontSize;

  const StatusChip({super.key, required this.status, this.fontSize = 12});

  Color get _color {
    switch (status) {
      case BookingStatus.pending: return const Color(0xFFF59E0B);
      case BookingStatus.approved: return const Color(0xFF10B981);
      case BookingStatus.rejected: return const Color(0xFFEF4444);
      case BookingStatus.cancelled: return Colors.grey;
      case BookingStatus.completed: return const Color(0xFF06B6D4);
    }
  }

  IconData get _icon {
    switch (status) {
      case BookingStatus.pending: return Icons.schedule;
      case BookingStatus.approved: return Icons.check_circle;
      case BookingStatus.rejected: return Icons.cancel;
      case BookingStatus.cancelled: return Icons.block;
      case BookingStatus.completed: return Icons.task_alt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: fontSize, color: _color),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}
