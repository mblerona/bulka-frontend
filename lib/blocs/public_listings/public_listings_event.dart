part of 'public_listings_bloc.dart';

sealed class PublicListingsEvent {
  const PublicListingsEvent();
}

/// Load (or reload) Home's recommended listings in [languageCode].
final class RecommendedListingsRequested extends PublicListingsEvent {
  const RecommendedListingsRequested(this.languageCode);

  final String languageCode;
}

/// Search with [filter] (replaces the current results).
final class ListingSearchRequested extends PublicListingsEvent {
  const ListingSearchRequested(this.filter, this.languageCode);

  final ListingSearchFilter filter;
  final String languageCode;
}

/// Load the next page of the current search results.
final class MoreSearchResultsRequested extends PublicListingsEvent {
  const MoreSearchResultsRequested();
}

/// Load (or reload) one listing's details, items and prices.
final class ListingDetailsRequested extends PublicListingsEvent {
  const ListingDetailsRequested(this.slug, this.languageCode);

  final String slug;
  final String languageCode;
}
