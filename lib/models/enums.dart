import 'package:flutter/material.dart';

enum UserRole {
  studentCoordinator,
  facultyCoordinator,
  hod,
  venueIncharge,
  superAdmin;

  String get displayName {
    switch (this) {
      case UserRole.studentCoordinator:
        return 'Student Coordinator';
      case UserRole.facultyCoordinator:
        return 'Faculty Coordinator';
      case UserRole.hod:
        return 'Head of Department';
      case UserRole.venueIncharge:
        return 'Venue In-Charge';
      case UserRole.superAdmin:
        return 'Administrator';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.studentCoordinator:
        return Icons.school_rounded;
      case UserRole.facultyCoordinator:
        return Icons.co_present_rounded;
      case UserRole.hod:
        return Icons.corporate_fare_rounded;
      case UserRole.venueIncharge:
        return Icons.meeting_room_rounded;
      case UserRole.superAdmin:
        return Icons.admin_panel_settings_rounded;
    }
  }

  bool get canApproveBookings {
    return this != UserRole.studentCoordinator;
  }
}

/// Booking status aligned with the multi-stage approval workflow.
enum BookingStatus {
  pendingFaculty,
  pendingHod,
  pendingVenue,
  confirmed,
  rejected,
  cancelled,
  completed,
  changesRequested;

  String get displayName {
    switch (this) {
      case BookingStatus.pendingFaculty:
        return 'Pending Faculty';
      case BookingStatus.pendingHod:
        return 'Pending HOD';
      case BookingStatus.pendingVenue:
        return 'Pending Venue';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.rejected:
        return 'Rejected';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.changesRequested:
        return 'Changes Requested';
    }
  }

  /// Whether this status represents a "pending" state.
  bool get isPending =>
      this == BookingStatus.pendingFaculty ||
      this == BookingStatus.pendingHod ||
      this == BookingStatus.pendingVenue;

  Color get color {
    switch (this) {
      case BookingStatus.pendingFaculty:
      case BookingStatus.pendingHod:
      case BookingStatus.pendingVenue:
        return const Color(0xFFD97706);
      case BookingStatus.confirmed:
        return const Color(0xFF16A34A);
      case BookingStatus.rejected:
        return const Color(0xFFDC2626);
      case BookingStatus.cancelled:
        return const Color(0xFF64748B);
      case BookingStatus.completed:
        return const Color(0xFF2563EB);
      case BookingStatus.changesRequested:
        return const Color(0xFFEA580C);
    }
  }

  Color get bgColor {
    switch (this) {
      case BookingStatus.pendingFaculty:
      case BookingStatus.pendingHod:
      case BookingStatus.pendingVenue:
        return const Color(0xFFFEF3C7);
      case BookingStatus.confirmed:
        return const Color(0xFFDCFCE7);
      case BookingStatus.rejected:
        return const Color(0xFFFEE2E2);
      case BookingStatus.cancelled:
        return const Color(0xFFF1F5F9);
      case BookingStatus.completed:
        return const Color(0xFFDBEAFE);
      case BookingStatus.changesRequested:
        return const Color(0xFFFFF7ED);
    }
  }

  IconData get icon {
    switch (this) {
      case BookingStatus.pendingFaculty:
      case BookingStatus.pendingHod:
      case BookingStatus.pendingVenue:
        return Icons.schedule_rounded;
      case BookingStatus.confirmed:
        return Icons.check_circle_rounded;
      case BookingStatus.rejected:
        return Icons.cancel_rounded;
      case BookingStatus.cancelled:
        return Icons.block_rounded;
      case BookingStatus.completed:
        return Icons.task_alt_rounded;
      case BookingStatus.changesRequested:
        return Icons.edit_note_rounded;
    }
  }
}

/// The stage in the approval pipeline. Each stage maps 1:1 with a BookingStatus.
enum ApprovalStage {
  submitted,
  facultyApproved,
  hodApproved,
  venueApproved,
  rejected,
  changesRequested;

  String get displayName {
    switch (this) {
      case ApprovalStage.submitted:
        return 'Awaiting Faculty Approval';
      case ApprovalStage.facultyApproved:
        return 'Awaiting HOD Approval';
      case ApprovalStage.hodApproved:
        return 'Awaiting Venue In-Charge Approval';
      case ApprovalStage.venueApproved:
        return 'Fully Confirmed';
      case ApprovalStage.rejected:
        return 'Rejected';
      case ApprovalStage.changesRequested:
        return 'Changes Requested';
    }
  }

  /// Map each approval stage to the corresponding booking status.
  BookingStatus get toBookingStatus {
    switch (this) {
      case ApprovalStage.submitted:
        return BookingStatus.pendingFaculty;
      case ApprovalStage.facultyApproved:
        return BookingStatus.pendingHod;
      case ApprovalStage.hodApproved:
        return BookingStatus.pendingVenue;
      case ApprovalStage.venueApproved:
        return BookingStatus.confirmed;
      case ApprovalStage.rejected:
        return BookingStatus.rejected;
      case ApprovalStage.changesRequested:
        return BookingStatus.changesRequested;
    }
  }
}

/// Notification event types.
enum NotificationType {
  bookingSubmitted,
  bookingApproved,
  bookingRejected,
  bookingModified,
  bookingCancelled,
  bookingConfirmed,
  changesRequested,
  general;

  String get displayName {
    switch (this) {
      case NotificationType.bookingSubmitted:
        return 'Booking Submitted';
      case NotificationType.bookingApproved:
        return 'Booking Approved';
      case NotificationType.bookingRejected:
        return 'Booking Rejected';
      case NotificationType.bookingModified:
        return 'Booking Modified';
      case NotificationType.bookingCancelled:
        return 'Booking Cancelled';
      case NotificationType.bookingConfirmed:
        return 'Booking Confirmed';
      case NotificationType.changesRequested:
        return 'Changes Requested';
      case NotificationType.general:
        return 'Notification';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.bookingSubmitted:
        return Icons.send_rounded;
      case NotificationType.bookingApproved:
        return Icons.thumb_up_alt_rounded;
      case NotificationType.bookingRejected:
        return Icons.thumb_down_alt_rounded;
      case NotificationType.bookingModified:
        return Icons.edit_rounded;
      case NotificationType.bookingCancelled:
        return Icons.cancel_rounded;
      case NotificationType.bookingConfirmed:
        return Icons.check_circle_rounded;
      case NotificationType.changesRequested:
        return Icons.edit_note_rounded;
      case NotificationType.general:
        return Icons.notifications_rounded;
    }
  }
}
