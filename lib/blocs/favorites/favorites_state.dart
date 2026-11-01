part of 'favorites_bloc.dart';

final class FavoritesState {
  FavoritesState(Set<String> listingIds)
    : listingIds = Set.unmodifiable(listingIds);

  final Set<String> listingIds;

  bool isFavorite(String listingId) => listingIds.contains(listingId);
}
