import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/models/support_attachment.dart';

/// A support ticket's lifecycle state. [label]/[pillTextColor] centralize
/// the Figma status styling here instead of scattering raw status strings
/// or color-picking logic across the widgets that render a ticket.
enum TicketStatus {
  open,
  inProgress,
  resolved;

  String get label {
    switch (this) {
      case TicketStatus.open:
        return AppStrings.ticketStatusOpen;
      case TicketStatus.inProgress:
        return AppStrings.ticketStatusInProgress;
      case TicketStatus.resolved:
        return AppStrings.ticketStatusResolved;
    }
  }

  Color get pillTextColor {
    switch (this) {
      case TicketStatus.open:
        return AppColors.agroInk500;
      // Figma's "agro-gold-600" (#D1BFA7) is the same hex already defined
      // as AppColors.agroGold100 (used for the "not verified" badge).
      case TicketStatus.inProgress:
        return AppColors.agroGold100;
      case TicketStatus.resolved:
        return AppColors.agroForest950;
    }
  }
}

/// A support ticket. Shaped to map directly onto a future support API
/// response so the mock data + local creation in `SupportTicketController`
/// can be swapped for real fetched/created records without changing this
/// model or anything that reads it.
class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    this.attachment,
  });

  /// Numeric-looking ticket reference, e.g. "58" — rendered as "#58".
  final String id;

  final String category;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TicketStatus status;
  final SupportAttachment? attachment;
}
