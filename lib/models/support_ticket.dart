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
  resolved,
  closed;

  /// The backend's status name. Anything unrecognized shows as [open].
  static TicketStatus fromApi(String? value) {
    switch (value) {
      case 'InProgress':
        return TicketStatus.inProgress;
      case 'Resolved':
        return TicketStatus.resolved;
      case 'Closed':
        return TicketStatus.closed;
      default:
        return TicketStatus.open;
    }
  }

  String get label {
    switch (this) {
      case TicketStatus.open:
        return AppStrings.ticketStatusOpen;
      case TicketStatus.inProgress:
        return AppStrings.ticketStatusInProgress;
      case TicketStatus.resolved:
        return AppStrings.ticketStatusResolved;
      case TicketStatus.closed:
        return AppStrings.ticketStatusClosed;
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
      case TicketStatus.closed:
        return AppColors.profileSecondaryText;
    }
  }
}

/// A support ticket, from `GET /api/me/tickets`.
class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.number,
    required this.category,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    this.attachments = const [],
  });

  /// The response has no "last changed" time, so [updatedAt] is the latest
  /// of when the ticket was created, was closed or got a message.
  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    final createdAt = _parseDate(json['createdAtUtc']) ?? DateTime.now();
    final activity = [
      json['closedAtUtc'],
      for (final message in json['messages'] as List<dynamic>? ?? const [])
        if (message is Map<String, dynamic>) message['createdAtUtc'],
    ].map(_parseDate).whereType<DateTime>();
    return SupportTicket(
      id: json['id'] as String? ?? '',
      number: json['ticketNumber'] as String? ?? '',
      category: json['type'] as String? ?? '',
      title: json['subject'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt: createdAt,
      updatedAt: activity.fold(
        createdAt,
        (latest, time) => time.isAfter(latest) ? time : latest,
      ),
      status: TicketStatus.fromApi(json['status'] as String?),
      attachments: [
        for (final item in json['attachments'] as List<dynamic>? ?? const [])
          if (item is Map<String, dynamic>) SupportAttachment.fromJson(item),
      ],
    );
  }

  static DateTime? _parseDate(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;

  final String id;

  /// The reference shown to the user, as the backend formats it.
  final String number;

  final String category;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TicketStatus status;
  final List<SupportAttachment> attachments;

  /// [category] in the current language. The backend sends a type name
  /// ("Booking"); a ticket created on this device already holds the label.
  String get categoryLabel {
    switch (category) {
      case 'Booking':
        return AppStrings.newTicketCategoryReservations;
      case 'Listing':
        return AppStrings.newTicketCategoryListings;
      case 'Payment':
        return AppStrings.newTicketCategoryPayments;
      case 'Account':
      case 'Profile':
        return AppStrings.newTicketCategoryProfile;
      case 'Other':
        return AppStrings.newTicketCategoryOther;
      default:
        return category;
    }
  }
}
