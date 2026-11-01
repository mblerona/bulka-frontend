part of 'search_bloc.dart';

sealed class SearchEvent {
  const SearchEvent();
}

/// From the filter sheet or the Search Results quick-filter chips.
final class SearchFilterApplied extends SearchEvent {
  const SearchFilterApplied(this.filter);

  final ListingSearchFilter filter;
}
