import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/utils/ago_label.dart';
import 'package:bulka_frontend/models/provider_listing.dart';
import 'package:bulka_frontend/screens/create_offer_wizard_screen/create_offer_wizard_screen.dart';
import 'package:bulka_frontend/services/provider_listing_controller.dart';
import 'package:bulka_frontend/widgets/app_bottom_nav.dart';
import 'package:bulka_frontend/widgets/primary_button.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';
import 'package:bulka_frontend/widgets/status_badge.dart';
import 'package:bulka_frontend/widgets/xfile_image.dart';

class _FilterOption {
  const _FilterOption(this.label, this.status);
  final String label;
  final ListingStatus? status;
}

const List<_FilterOption> _filters = [
  _FilterOption(AppStrings.offersFilterAll, null),
  _FilterOption(AppStrings.offersFilterActive, ListingStatus.active),
  _FilterOption(
    AppStrings.offersFilterPendingReview,
    ListingStatus.pendingReview,
  ),
  _FilterOption(AppStrings.offersFilterRejected, ListingStatus.rejected),
];

class ProviderOffersScreen extends StatefulWidget {
  const ProviderOffersScreen({super.key});

  @override
  State<ProviderOffersScreen> createState() => _ProviderOffersScreenState();
}

class _ProviderOffersScreenState extends State<ProviderOffersScreen> {
  final ProviderListingController _controller = ProviderListingController.instance;

  // null == "Сите" (all) — local UI state, since only this screen cares
  // which filter is currently selected.
  ListingStatus? _selectedFilter;

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

  @override
  Widget build(BuildContext context) {
    final listings = _controller.filteredListings(status: _selectedFilter);

    return Scaffold(
      backgroundColor: AppColors.white,
      bottomNavigationBar: const ProviderBottomNav(selectedIndex: 1),
      body: Column(
        children: [
          const ScreenHeader(
            title: AppStrings.offersTitle,
            subtitle: AppStrings.offersSubtitle,
            titleFontSize: AppDimensions.dsHeaderSubtitleTitleFontSize,
            bottomPadding: AppDimensions.dsCompactHeaderBottomPadding,
            contentGap: AppDimensions.dsRootHeaderGap,
            subtitleFontSize: AppDimensions.dsSubheadingFontSize,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: AppDimensions.dsBodyHorizontalPadding,
                  right: AppDimensions.dsBodyHorizontalPadding,
                  top: AppDimensions.dsRootBodyTopPadding,
                  bottom: AppDimensions.profileBodyBottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PrimaryButton(
                      label: AppStrings.dashboardAddListingButton,
                      backgroundColor: AppColors.agroGreen600,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CreateOfferWizardScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.offersBodyGap),
                    _FilterChipRow(
                      selected: _selectedFilter,
                      onSelected: (status) {
                        setState(() => _selectedFilter = status);
                      },
                    ),
                    const SizedBox(height: AppDimensions.offersBodyGap),
                    for (var i = 0; i < listings.length; i++) ...[
                      _ListingCard(
                        listing: listings[i],
                        onReactivate: () =>
                            _controller.reactivateListing(listings[i].id),
                      ),
                      if (i != listings.length - 1)
                        const SizedBox(height: AppDimensions.offersBodyGap),
                    ],
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

class _FilterChipRow extends StatelessWidget {
  const _FilterChipRow({required this.selected, required this.onSelected});

  final ListingStatus? selected;
  final ValueChanged<ListingStatus?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < _filters.length; i++) ...[
            _FilterChip(
              label: _filters[i].label,
              isSelected: _filters[i].status == selected,
              onTap: () => onSelected(_filters[i].status),
            ),
            if (i != _filters.length - 1)
              const SizedBox(width: AppDimensions.offersFilterChipGap),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.offersFilterChipHorizontalPadding,
          vertical: AppDimensions.offersFilterChipVerticalPadding,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.agroForest950 : AppColors.white,
          border: isSelected
              ? null
              : Border.all(color: AppColors.profileStatCardBorder),
          borderRadius: BorderRadius.circular(AppDimensions.pillBorderRadius),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            fontSize: AppDimensions.offersFilterChipFontSize,
            color: isSelected ? AppColors.white : AppColors.profileSecondaryText,
          ),
        ),
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({required this.listing, required this.onReactivate});

  final ProviderListing listing;
  final VoidCallback onReactivate;

  String? get _infoLine {
    switch (listing.status) {
      case ListingStatus.active:
        final ratingText = listing.rating != null
            ? ' · ${listing.rating!.toStringAsFixed(1)} ★'
            : '';
        return '${listing.reservationCount} '
            '${AppStrings.listingReservationsThisMonthLabel}$ratingText';
      case ListingStatus.pendingReview:
        return '${AppStrings.listingSubmittedForReviewLabel} '
            '${agoLabel(listing.updatedAt)}.';
      case ListingStatus.rejected:
        return '${AppStrings.listingRejectedReasonPrefix}'
            '${listing.rejectionReason ?? ''}';
      case ListingStatus.archived:
        return '${AppStrings.listingArchivedOnLabel} '
            '${_formatDate(listing.updatedAt)}.';
    }
  }

  Widget? _buildAction() {
    switch (listing.status) {
      case ListingStatus.active:
        return _OfferActionButton(
          label: AppStrings.editListingButton,
          // TODO: navigate to an Edit Listing screen once one exists.
          onTap: () {},
        );
      case ListingStatus.pendingReview:
        return null;
      case ListingStatus.rejected:
        return _OfferActionButton(
          label: AppStrings.editAndResubmitListingButton,
          // TODO: navigate to an Edit Listing screen once one exists —
          // resubmission should happen after a successful edit there.
          onTap: () {},
        );
      case ListingStatus.archived:
        return _OfferActionButton(
          label: AppStrings.reactivateListingButton,
          onTap: onReactivate,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final action = _buildAction();
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.profileStatCardBackground,
        border: Border.all(color: AppColors.profileStatCardBorder),
        borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          listing.photoPaths.isEmpty
              ? Container(
                  width: double.infinity,
                  height: AppDimensions.offersCardImageHeight,
                  color: AppColors.profileSoftMint,
                )
              : XFileImage(
                  path: listing.photoPaths.first,
                  width: double.infinity,
                  height: AppDimensions.offersCardImageHeight,
                  fit: BoxFit.cover,
                ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.offersCardInfoPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        listing.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: AppDimensions.offersCardTitleFontSize,
                          color: AppColors.agroForest950,
                        ),
                      ),
                    ),
                    StatusBadge(
                      label: listing.status.label,
                      backgroundColor: listing.status.badgeBackground,
                      textColor: listing.status.badgeTextColor,
                      horizontalPadding:
                          AppDimensions.dsStatusPillHorizontalPadding,
                      verticalPadding: AppDimensions.dsStatusPillVerticalPadding,
                      fontSize: AppDimensions.dsStatusPillFontSize,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.offersCardInfoGap),
                Text(
                  listing.location,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: AppDimensions.offersCardMetaFontSize,
                    color: AppColors.profileSecondaryText,
                  ),
                ),
                if (_infoLine != null) ...[
                  const SizedBox(height: AppDimensions.offersCardInfoGap),
                  Text(
                    _infoLine!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: AppDimensions.offersCardMetaFontSize,
                      color: AppColors.profileSecondaryText,
                    ),
                  ),
                ],
                if (action != null) ...[
                  const SizedBox(height: AppDimensions.offersCardInfoGap),
                  SizedBox(width: double.infinity, child: action),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferActionButton extends StatelessWidget {
  const _OfferActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.dashboardActionButtonVerticalPadding,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.profileStatCardBorder),
          borderRadius: BorderRadius.circular(
            AppDimensions.dashboardActionButtonRadius,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: AppDimensions.dashboardActionButtonFontSize,
            color: AppColors.agroInk500,
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month.${date.year}';
}
