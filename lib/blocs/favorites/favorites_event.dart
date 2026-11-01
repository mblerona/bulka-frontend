part of 'favorites_bloc.dart';

sealed class FavoritesEvent {
  const FavoritesEvent();
}

/// Adds the listing to favourites, or removes it if it's already there.
final class FavoriteToggled extends FavoritesEvent {
  const FavoriteToggled(this.listingId);

  final String listingId;
}
