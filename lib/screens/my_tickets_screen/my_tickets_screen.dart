import 'package:flutter/material.dart';
import 'package:bulka_frontend/blocs/support_tickets/support_tickets_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/core/routing/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/utils/ago_label.dart';
import 'package:bulka_frontend/models/support_ticket.dart';
import 'package:bulka_frontend/widgets/load_failed_message.dart';
import 'package:bulka_frontend/widgets/primary_button.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';
import 'package:bulka_frontend/widgets/status_badge.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  void _loadTickets() {
    context.read<SupportTicketsBloc>().add(const SupportTicketsRequested());
  }

  void _openNewTicket() {
    context.push(AppRoutes.newTicket);
  }

  /// Shown above the button when there are no tickets to list.
  Widget _noTicketsMessage(SupportTicketsStatus status) {
    switch (status) {
      case SupportTicketsStatus.initial:
      case SupportTicketsStatus.loading:
        return const SectionLoadingIndicator();
      case SupportTicketsStatus.failed:
      case SupportTicketsStatus.notFound: // Only for a ticket's details.
        return LoadFailedMessage(
          message: AppStrings.ticketsLoadFailed,
          onRetry: _loadTickets,
        );
      case SupportTicketsStatus.loaded:
        return Text(
          AppStrings.ticketsEmpty,
          style: const TextStyle(
            fontSize: AppDimensions.dsInputFontSize,
            color: AppColors.profileSecondaryText,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SupportTicketsBloc>().state;
    final tickets = state.tickets;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          ScreenHeader(
            title: AppStrings.myTicketsTitle,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (tickets.isEmpty) ...[
                      _noTicketsMessage(state.status),
                      const SizedBox(height: AppDimensions.myTicketsCardGap),
                    ],
                    for (final ticket in tickets) ...[
                      _TicketCard(ticket: ticket),
                      const SizedBox(height: AppDimensions.myTicketsCardGap),
                    ],
                    PrimaryButton(
                      label: AppStrings.createTicketButton,
                      backgroundColor: AppColors.agroGreen600,
                      onPressed: _openNewTicket,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket});

  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push(AppRoutes.ticket(ticket.id)),
      child: _card(),
    );
  }

  Widget _card() {
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
              // Backend numbers are long ("HD-20260826190835-9486").
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
            '${AppStrings.ticketLastChangedLabel}: ${agoLabel(ticket.updatedAt)}',
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: AppDimensions.myTicketsLastChangedFontSize,
              color: AppColors.profileSecondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
