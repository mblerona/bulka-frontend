import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/blocs/listings/listings_mock_data.dart';
import 'package:bulka_frontend/models/create_listing_draft.dart';
import 'package:bulka_frontend/models/provider_listing.dart';

part 'listings_event.dart';
part 'listings_state.dart';

/// All provider listings — the Provider's own offers and, for Tourists,
/// the active ones they can browse and book. Mock data until the listings
/// API is connected.
class ListingsBloc extends Bloc<ListingsEvent, ListingsState> {
  ListingsBloc({List<ProviderListing>? initialListings})
    : super(ListingsState(initialListings ?? mockListings())) {
    on<ListingCreated>(_onListingCreated);
    on<ListingReactivated>(_onListingReactivated);
  }

  int _nextListingId = 10;

  /// A new listing from the Create Offer wizard; it starts "in review".
  void _onListingCreated(ListingCreated event, Emitter<ListingsState> emit) {
    final draft = event.draft;
    final listing = ProviderListing(
      id: '${_nextListingId++}',
      title: draft.title.trim(),
      status: ListingStatus.pendingReview,
      location: draft.location.trim(),
      updatedAt: DateTime.now(),
      category: draft.category,
      description: draft.description.trim(),
      price: draft.price ?? 0,
      guestCapacity: draft.guestCapacity,
      roomCount: draft.roomCount,
      bedCount: draft.bedCount,
      amenities: Set.of(draft.amenities),
      photoPaths: draft.photos.map((f) => f.path).toList(),
    );
    emit(ListingsState([listing, ...state.listings]));
  }

  void _onListingReactivated(
    ListingReactivated event,
    Emitter<ListingsState> emit,
  ) {
    if (state.byId(event.listingId) == null) return;
    final now = DateTime.now();
    emit(
      ListingsState([
        for (final l in state.listings)
          if (l.id == event.listingId)
            l.copyWith(status: ListingStatus.active, updatedAt: now)
          else
            l,
      ]),
    );
  }
}
