import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/blocs/listing_reviews/listing_reviews_bloc.dart';
import 'package:bulka_frontend/blocs/listings/listings_bloc.dart';
import 'package:bulka_frontend/models/listing_search_filter.dart';
import 'package:bulka_frontend/models/provider_listing.dart';

part 'search_event.dart';
part 'search_state.dart';

/// The Tourist's current search filter (Search Results, filter sheet).
/// Which listings match is worked out by [searchListings], from this state
/// plus the listings and reviews.
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchState(ListingSearchFilter())) {
    on<SearchFilterApplied>((event, emit) => emit(SearchState(event.filter)));
  }
}

/// The active listings that match [filter]. Ratings come from the reviews
/// (see [ListingReviewsState.effectiveRating]).
List<ProviderListing> searchListings({
  required ListingSearchFilter filter,
  required ListingsState listings,
  required ListingReviewsState reviews,
}) {
  final keyword = filter.keyword.trim().toLowerCase();
  return listings.active.where((listing) {
    if (keyword.isNotEmpty) {
      final haystack =
          '${listing.title} ${listing.location} ${listing.description}'
              .toLowerCase();
      if (!haystack.contains(keyword)) return false;
    }
    if (filter.location != null && listing.location != filter.location) {
      return false;
    }
    if (filter.minPrice != null && listing.price < filter.minPrice!) {
      return false;
    }
    if (filter.maxPrice != null && listing.price > filter.maxPrice!) {
      return false;
    }
    if (filter.minRating != null) {
      final rating = reviews.effectiveRating(listing);
      if (rating == null || rating < filter.minRating!) return false;
    }
    if (filter.minimumGuests != null &&
        listing.guestCapacity < filter.minimumGuests!) {
      return false;
    }
    if (filter.categories.isNotEmpty &&
        !filter.categories.contains(listing.category)) {
      return false;
    }
    if (filter.amenities.isNotEmpty) {
      final codes = listing.amenities.map((a) => a.backendCode).toSet();
      if (!filter.amenities.every(codes.contains)) return false;
    }
    return true;
  }).toList();
}
