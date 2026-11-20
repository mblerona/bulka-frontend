import 'package:flutter/material.dart';
import 'package:bulka_frontend/blocs/support_tickets/support_tickets_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/utils/ago_label.dart';
import 'package:bulka_frontend/core/utils/date_range_format.dart';
import 'package:bulka_frontend/models/support_attachment.dart';
import 'package:bulka_frontend/models/support_ticket.dart';
import 'package:bulka_frontend/screens/route_not_found_screen/route_not_found_screen.dart';
import 'package:bulka_frontend/widgets/listing_image.dart';
import 'package:bulka_frontend/widgets/load_failed_message.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';
import 'package:bulka_frontend/widgets/status_badge.dart';
import 'package:bulka_frontend/widgets/xfile_image.dart';

/// One support ticket, opened from My Tickets: everything entered on the
/// New Support Ticket screen (category, title, description, attachment),
/// plus its number, status and dates. Loads `GET /api/me/tickets/{id}`.
class TicketDetailsScreen extends StatefulWidget {
  const TicketDetailsScreen({super.key, required this.ticketId});

  final String ticketId;

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    context.read<SupportTicketsBloc>().add(
      SupportTicketDetailsRequested(widget.ticketId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SupportTicketsBloc>().state;
    final ticket = state.detailsFor(widget.ticketId);
    final status = state.detailsStatusFor(widget.ticketId);

    if (ticket == null && status == SupportTicketsStatus.notFound) {
      return const RouteNotFoundScreen();
    }

    final Widget body;
    if (ticket != null) {
      body = _TicketDetailsBody(ticket: ticket);
    } else if (status == SupportTicketsStatus.failed) {
      body = LoadFailedMessage(
        message: AppStrings.ticketDetailsLoadFailed,
        onRetry: _load,
      );
    } else {
      body = const SectionLoadingIndicator();
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          ScreenHeader(
            title: AppStrings.ticketDetailsTitle,
            titleFontSize: AppDimensions.dsCompactHeaderTitleFontSize,
            bottomPadding: AppDimensions.dsCompactHeaderBottomPadding,
            contentGap: AppDimensions.dsCompactHeaderGap,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: AppDimensions.dsBodyHorizontalPadding,
                  right: AppDimensions.dsBodyHorizontalPadding,
                  top: AppDimensions.myTicketsBodyTopPadding,
                  bottom: AppDimensions.profileBodyBottomPadding,
                ),
                child: body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketDetailsBody extends StatelessWidget {
  const _TicketDetailsBody({required this.ticket});

  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    final description = ticket.description.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryCard(ticket: ticket),
        const SizedBox(height: AppDimensions.newTicketBodyGap),
        _Field(
          label: AppStrings.newTicketCategoryLabel,
          child: _ValueText(ticket.categoryLabel),
        ),
        const SizedBox(height: AppDimensions.newTicketBodyGap),
        _Field(
          label: AppStrings.newTicketTitleLabel,
          child: _ValueText(ticket.title),
        ),
        if (description.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.newTicketBodyGap),
          _Field(
            label: AppStrings.newTicketDescriptionLabel,
            child: _ValueText(description),
          ),
        ],
        if (ticket.attachments.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.newTicketBodyGap),
          Text(AppStrings.ticketAttachmentLabel, style: _labelStyle),
          for (final attachment in ticket.attachments) ...[
            const SizedBox(height: AppDimensions.newTicketFieldGap),
            _AttachmentView(attachment: attachment),
          ],
        ],
      ],
    );
  }
}

const _labelStyle = TextStyle(
  fontWeight: FontWeight.w600,
  fontSize: AppDimensions.dsFieldLabelFontSize,
  color: AppColors.agroForest950,
);

const _secondaryStyle = TextStyle(
  fontWeight: FontWeight.w400,
  fontSize: AppDimensions.myTicketsLastChangedFontSize,
  color: AppColors.profileSecondaryText,
);

final _fieldDecoration = BoxDecoration(
  color: AppColors.white,
  border: Border.all(color: AppColors.profileStatCardBorder),
  borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
);

/// Number, status, title and dates, styled like the My Tickets card.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.ticket});

  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.myTicketsCardPadding),
      decoration: BoxDecoration(
        color: AppColors.agroCream100,
        border: Border.all(color: AppColors.profileStatCardBorder),
        borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  ticket.number,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: AppDimensions.myTicketsTicketNumberFontSize,
                    color: AppColors.agroGreen700,
                  ),
                ),
              ),
              StatusBadge(
                label: ticket.status.label,
                backgroundColor: AppColors.white,
                textColor: ticket.status.pillTextColor,
                horizontalPadding: AppDimensions.dsStatusPillHorizontalPadding,
                verticalPadding: AppDimensions.dsStatusPillVerticalPadding,
                fontSize: AppDimensions.dsStatusPillFontSize,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.myTicketsCardRowGap),
          Text(
            ticket.title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: AppDimensions.myTicketsTitleFontSize,
              color: AppColors.agroForest950,
            ),
          ),
          const SizedBox(height: AppDimensions.myTicketsCardRowGap),
          Text(
            '${AppStrings.ticketCreatedLabel}: '
            '${formatDateShort(ticket.createdAt.toLocal())}',
            style: _secondaryStyle,
          ),
          Text(
            '${AppStrings.ticketLastChangedLabel}: ${agoLabel(ticket.updatedAt)}',
            style: _secondaryStyle,
          ),
        ],
      ),
    );
  }
}

/// A label above a read-only box, matching the New Support Ticket fields.
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: _labelStyle),
        const SizedBox(height: AppDimensions.newTicketFieldGap),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.dsInputHorizontalPadding,
            vertical: AppDimensions.dsInputVerticalPadding,
          ),
          decoration: _fieldDecoration,
          child: child,
        ),
      ],
    );
  }
}

class _ValueText extends StatelessWidget {
  const _ValueText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: AppDimensions.dsInputFontSize,
        color: AppColors.agroForest950,
      ),
    );
  }
}

/// An image attachment as a preview; any other file as a name row like
/// the one on New Support Ticket.
class _AttachmentView extends StatelessWidget {
  const _AttachmentView({required this.attachment});

  final SupportAttachment attachment;

  Widget? _imagePreview() {
    if (attachment.type != SupportAttachmentType.image) return null;
    const height = AppDimensions.ticketDetailsAttachmentImageHeight;
    final url = attachment.url;
    if (url != null) return ListingImage(url: url, height: height);
    if (attachment.localPath.isNotEmpty) {
      return XFileImage(
        path: attachment.localPath,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final preview = _imagePreview();
    if (preview != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
        child: preview,
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.dsInputHorizontalPadding,
        vertical: AppDimensions.dsInputVerticalPadding,
      ),
      decoration: _fieldDecoration,
      child: Row(
        children: [
          Icon(
            attachment.type == SupportAttachmentType.image
                ? Icons.image_outlined
                : Icons.insert_drive_file_outlined,
            size: AppDimensions.newTicketAttachmentRowIconSize,
            color: AppColors.agroInk500,
          ),
          const SizedBox(width: AppDimensions.newTicketAttachmentRowGap),
          Expanded(
            child: Text(
              attachment.fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _labelStyle,
            ),
          ),
        ],
      ),
    );
  }
}
