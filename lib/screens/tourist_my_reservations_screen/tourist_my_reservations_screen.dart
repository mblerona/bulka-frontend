import 'package:flutter/material.dart';
import 'package:bulka_frontend/blocs/auth/auth_bloc.dart';
import 'package:bulka_frontend/blocs/reservations/reservations_bloc.dart';
import 'package:bulka_frontend/blocs/listings/listings_bloc.dart';
import 'package:bulka_frontend/blocs/public_listings/public_listings_bloc.dart';
import 'package:bulka_frontend/core/utils/booked_listing.dart';
import 'package:bulka_frontend/blocs/listing_reviews/listing_reviews_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/core/routing/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/utils/date_range_format.dart';
import 'package:bulka_frontend/core/utils/price_format.dart';
import 'package:bulka_frontend/models/provider_listing.dart';
import 'package:bulka_frontend/models/reservation.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';
import 'package:bulka_frontend/widgets/status_badge.dart';
import 'package:bulka_frontend/widgets/xfile_image.dart';

enum ReservationsTab { upcoming, past }

/// The Figma "26 – Buyer · My Bookings" frame (both the "Претстојни" and
/// "Минати" (26b) states) — one screen, one local [ReservationsTab], not
/// two routes. Reads exclusively from `ReservationsBloc`/`ListingsBloc` —
/// the same `Reservation` objects the booking flow creates and the Provider
/// Dashboard/Calendar already consume, so an accept/reject or a status
/// change is reflected here automatically, with nothing manually copied
/// between separate lists.
class TouristMyReservationsScreen extends StatefulWidget {
  const TouristMyReservationsScreen({
    super.key,
    this.initialTab = ReservationsTab.upcoming,
  });

  final ReservationsTab initialTab;

  @override
  State<TouristMyReservationsScreen> createState() =>
      _TouristMyReservationsScreenState();
}

class _TouristMyReservationsScreenState
    extends State<TouristMyReservationsScreen> {
  // Read here; `build` watches the same blocs so the screen rebuilds.
  ReservationsState get _reservations => context.read<ReservationsBloc>().state;
  ListingsState get _listings => context.read<ListingsBloc>().state;

  late ReservationsTab _tab;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
  }

  /// The signed-in Tourist's own bookings, matched by account id.
  List<Reservation> get _myReservations =>
      _reservations.forGuest(context.read<AuthBloc>().state.user?.id);

  List<Reservation> get _upcoming => _myReservations
      .where(
        (r) =>
            r.status == ReservationStatus.pending ||
            r.status == ReservationStatus.accepted,
      )
      .toList();

  List<Reservation> get _past => _myReservations
      .where((r) => r.status == ReservationStatus.completed)
      .toList();

  // TODO: `rejected`/`cancelled` reservations are intentionally not shown
  // in either tab yet. They remain safely in `ReservationsBloc`'s
  // shared state (nothing here hides or deletes them) — only this
  // screen's presentation of them is undecided, pending product
  // confirmation of where a no-longer-active reservation belongs on this
  // screen. Do not silently fold them into either tab above.

  ProviderListing? _resolveListing(Reservation reservation) {
    final listingId = reservation.listingId;
    if (listingId != null) {
      final listing = findBookedListing(context, listingId);
      if (listing != null) return listing;
    }
    for (final listing in _listings.listings) {
      if (listing.title == reservation.listingName) return listing;
    }
    return null;
  }

  List<(Reservation, ProviderListing)> _resolvedEntries(
    List<Reservation> reservations,
  ) {
    final entries = <(Reservation, ProviderListing)>[];
    for (final reservation in reservations) {
      final listing = _resolveListing(reservation);
      if (listing != null) entries.add((reservation, listing));
    }
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AuthBloc>();
    context.watch<ReservationsBloc>();
    context.watch<ListingsBloc>();
    context.watch<PublicListingsBloc>();
    final entries = _resolvedEntries(
      _tab == ReservationsTab.upcoming ? _upcoming : _past,
    );

    return Scaffold(
      backgroundColor: AppColors.beigeBackground,
      body: Column(
        children: [
          ScreenHeader(
            title: AppStrings.myReservationsTitle,
            titleFontSize: AppDimensions.dsCompactHeaderTitleFontSize,
            bottomPadding: AppDimensions.dsCompactHeaderBottomPadding,
            contentGap: AppDimensions.dsCompactHeaderGap,
          ),
          _TabsToggle(
            selected: _tab,
            onChanged: (tab) => setState(() => _tab = tab),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: entries.isEmpty
                  ? _EmptyState(tab: _tab)
                  : SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        left: AppDimensions.dsBodyHorizontalPadding,
                        right: AppDimensions.dsBodyHorizontalPadding,
                        top: AppDimensions.myReservationsListVerticalPadding,
                        bottom: AppDimensions.profileBodyBottomPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < entries.length; i++) ...[
                            _tab == ReservationsTab.upcoming
                                ? _UpcomingCard(
                                    reservation: entries[i].$1,
                                    listing: entries[i].$2,
                                  )
                                : _PastCard(
                                    reservation: entries[i].$1,
                                    listing: entries[i].$2,
                                  ),
                            if (i != entries.length - 1)
                              const SizedBox(
                                height: AppDimensions.myReservationsCardGap,
                              ),
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

class _TabsToggle extends StatelessWidget {
  const _TabsToggle({required this.selected, required this.onChanged});

  final ReservationsTab selected;
  final ValueChanged<ReservationsTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.dsBodyHorizontalPadding,
        right: AppDimensions.dsBodyHorizontalPadding,
        top: AppDimensions.myReservationsTabsTopPadding,
        bottom: AppDimensions.myReservationsTabsBottomPadding,
      ),
      child: Container(
        height: AppDimensions.providerSubjectToggleHeight,
        padding: const EdgeInsets.all(AppDimensions.dsToggleContainerPadding),
        decoration: BoxDecoration(
          color: AppColors.profileStatCardBackground,
          border: Border.all(color: AppColors.profileStatCardBorder),
          borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
        ),
        child: Row(
          children: [
            Expanded(
              child: _TabOption(
                label: AppStrings.upcomingTabLabel,
                isSelected: selected == ReservationsTab.upcoming,
                onTap: () => onChanged(ReservationsTab.upcoming),
              ),
            ),
            const SizedBox(width: AppDimensions.dsToggleOptionGap),
            Expanded(
              child: _TabOption(
                label: AppStrings.pastTabLabel,
                isSelected: selected == ReservationsTab.past,
                onTap: () => onChanged(ReservationsTab.past),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabOption extends StatelessWidget {
  const _TabOption({
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
        height: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.agroForest950 : Colors.transparent,
          borderRadius: BorderRadius.circular(
            AppDimensions.providerSubjectToggleOptionRadius,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: AppDimensions.dsToggleFontSize,
            color: isSelected ? AppColors.white : AppColors.agroForest950,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.tab});

  final ReservationsTab tab;

  @override
  Widget build(BuildContext context) {
    // No empty-state design exists in either Figma frame yet — this is a
    // minimal placeholder using existing typography/colors only, easy to
    // replace once one does.
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.dsBodyHorizontalPadding,
        ),
        child: Text(
          tab == ReservationsTab.upcoming
              ? AppStrings.myReservationsEmptyUpcoming
              : AppStrings.myReservationsEmptyPast,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: AppDimensions.detailsBodyFontSize,
            color: AppColors.profileSecondaryText,
          ),
        ),
      ),
    );
  }
}

String _guestsLabel(int count) {
  final suffix = count == 1
      ? AppStrings.reservationGuestSingular
      : AppStrings.reservationGuestsPlural;
  return '$count $suffix';
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({required this.reservation, required this.listing});

  final Reservation reservation;
  final ProviderListing listing;

  String get _metaLine =>
      '${formatDateRangeShortWithYear(reservation.startDate, reservation.endDate)}'
      ' · ${_guestsLabel(reservation.guestCount)}';

  String get _actionLabel {
    if (reservation.totalAmount == null) {
      return AppStrings.myReservationsDetailsButton;
    }
    return '${AppStrings.myReservationsDetailsButton} · '
        '${formatPrice(reservation.totalAmount!)} ${AppStrings.wizardPriceSuffix}';
  }

  @override
  Widget build(BuildContext context) {
    return _ReservationCard(
      listing: listing,
      statusLabel: reservation.status.touristLabel,
      metaLine: _metaLine,
      actionLabel: _actionLabel,
      // TODO: navigate to a Reservation Details screen once one exists.
      // This already carries the exact `reservation`/`listing` such a
      // screen would need — nothing hardcoded to resolve later.
      onTap: () {},
    );
  }
}

class _PastCard extends StatelessWidget {
  const _PastCard({required this.reservation, required this.listing});

  final Reservation reservation;
  final ProviderListing listing;

  String get _metaLine =>
      '${formatDateRangeShortWithYear(reservation.startDate, reservation.endDate)}'
      ' · ${_guestsLabel(reservation.guestCount)}';

  @override
  Widget build(BuildContext context) {
    final alreadyReviewed = context
        .watch<ListingReviewsBloc>()
        .state
        .hasReviewForReservation(reservation.id);
    return _ReservationCard(
      listing: listing,
      statusLabel: reservation.status.touristLabel,
      metaLine: _metaLine,
      actionLabel: AppStrings.leaveReviewButton,
      // No Figma design exists yet for an "already reviewed" state
      // (badge/label) — `enabled: false` only dims/disables the existing
      // action visually (same convention as ListingDetailsScreen's
      // non-bookable categories), rather than inventing new UI. TODO:
      // replace with a real "already reviewed" visual treatment once one
      // is designed. Real duplicate-review prevention lives in
      // `ListingReviewsBloc` regardless of this check.
      enabled: !alreadyReviewed,
      onTap: () => context.push(AppRoutes.leaveReview(reservation.id)),
    );
  }
}

/// Shared card shell for both tabs — pixel-identical to Search Results'
/// own listing cards (image/placeholder, info padding/gap, title+pill row,
/// meta line, full-width action button) except the top-right pill shows a
/// reservation status instead of a price, and the action button's
/// label/behavior differs per tab.
class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.listing,
    required this.statusLabel,
    required this.metaLine,
    required this.actionLabel,
    required this.onTap,
    this.enabled = true,
  });

  final ProviderListing listing;
  final String statusLabel;
  final String metaLine;
  final String actionLabel;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
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
                padding: const EdgeInsets.all(
                  AppDimensions.offersCardInfoPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                          label: statusLabel,
                          backgroundColor: AppColors.profileSoftMint,
                          textColor: AppColors.agroInk500,
                          horizontalPadding:
                              AppDimensions.profileRoleBadgeHorizontalPadding,
                          verticalPadding:
                              AppDimensions.profileRoleBadgeVerticalPadding,
                          fontSize: AppDimensions.profileRoleBadgeFontSize,
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
                    const SizedBox(height: AppDimensions.offersCardInfoGap),
                    Text(
                      metaLine,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: AppDimensions.offersCardMetaFontSize,
                        color: AppColors.profileSecondaryText,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.offersCardInfoGap),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical:
                            AppDimensions.dashboardActionButtonVerticalPadding,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        border: Border.all(color: AppColors.agroBorder300),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.dashboardActionButtonRadius,
                        ),
                      ),
                      child: Text(
                        actionLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: AppDimensions.dashboardActionButtonFontSize,
                          color: AppColors.agroInk500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
