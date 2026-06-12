import 'package:flutter/material.dart';

enum UserRole {
  studentCoordinator,
  teacher,
  departmentAdmin,
  superAdmin;

  String get displayName {
    switch (this) {
      case UserRole.studentCoordinator:
        return 'Student Coordinator';
      case UserRole.teacher:
        return 'Teacher / Faculty';
      case UserRole.departmentAdmin:
        return 'Department Admin';
      case UserRole.superAdmin:
        return 'Administrator';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.studentCoordinator:
        return Icons.school_rounded;
      case UserRole.teacher:
        return Icons.co_present_rounded;
      case UserRole.departmentAdmin:
        return Icons.corporate_fare_rounded;
      case UserRole.superAdmin:
        return Icons.admin_panel_settings_rounded;
    }
  }

  bool get canApproveBookings {
    return this == UserRole.departmentAdmin || this == UserRole.superAdmin;
  }
}

enum BookingStatus {
  pending,
  approved,
  rejected,
  cancelled,
  completed;

  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.approved:
        return 'Approved';
      case BookingStatus.rejected:
        return 'Rejected';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
    }
  }
}

enum ApprovalStage {
  submitted,
  coordinatorApproved,
  hodApproved,
  venueInChargeApproved,
  rejected;

  String get displayName {
    switch (this) {
      case ApprovalStage.submitted:
        return 'Awaiting Coordinator Approval';
      case ApprovalStage.coordinatorApproved:
        return 'Awaiting HOD Approval';
      case ApprovalStage.hodApproved:
        return 'Awaiting Venue In-Charge Approval';
      case ApprovalStage.venueInChargeApproved:
        return 'Fully Confirmed';
      case ApprovalStage.rejected:
        return 'Rejected';
    }
  }
}

