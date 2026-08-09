import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/models/support_ticket.dart';
import 'package:bulka_frontend/screens/new_support_ticket_screen/new_support_ticket_screen.dart';
import 'package:bulka_frontend/services/support_ticket_controller.dart';
import 'package:bulka_frontend/widgets/primary_button.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';
import 'package:bulka_frontend/widgets/status_badge.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  final SupportTicketController _controller = SupportTicketController.instance;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    super.dispose();
  }

  void _handleControllerChanged() => setState(() {});

  void _openNewTicket() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewSupportTicketScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tickets = _controller.tickets;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          const ScreenHeader(
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
              Text(
                '#${ticket.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: AppDimensions.myTicketsTicketNumberFontSize,
                  color: AppColors.agroGreen700,
                ),
              ),
              StatusBadge(
                label: ticket.status.label,
                backgroundColor: AppColors.white,
                textColor: ticket.status.pillTextColor,
                horizontalPadding: AppDimensions.myTicketsStatusPillHorizontalPadding,
                verticalPadding: AppDimensions.myTicketsStatusPillVerticalPadding,
                fontSize: AppDimensions.myTicketsStatusPillFontSize,
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
            '${AppStrings.ticketLastChangedLabel}: ${_agoLabel(ticket.updatedAt)}',
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

String _agoLabel(DateTime updatedAt) {
  final diff = DateTime.now().difference(updatedAt);
  final String amount;
  if (diff.inMinutes < 60) {
    amount = diff.inMinutes == 1
        ? '1 ${AppStrings.ticketMinuteSingular}'
        : '${diff.inMinutes} ${AppStrings.ticketMinutesPlural}';
  } else if (diff.inHours < 24) {
    amount = diff.inHours == 1
        ? '1 ${AppStrings.ticketHourSingular}'
        : '${diff.inHours} ${AppStrings.ticketHoursPlural}';
  } else {
    amount = diff.inDays == 1
        ? '1 ${AppStrings.ticketDaySingular}'
        : '${diff.inDays} ${AppStrings.ticketDaysPlural}';
  }
  return '${AppStrings.ticketAgoPrefix} $amount';
}
