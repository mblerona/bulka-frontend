part of 'listings_bloc.dart';

sealed class ListingsEvent {
  const ListingsEvent();
}

/// Published from the Create Offer wizard.
final class ListingCreated extends ListingsEvent {
  const ListingCreated(this.draft);

  final CreateListingDraft draft;
}

/// An archived/rejected listing made active again (Provider Offers).
final class ListingReactivated extends ListingsEvent {
  const ListingReactivated(this.listingId);

  final String listingId;
}
