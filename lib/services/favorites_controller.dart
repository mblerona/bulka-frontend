import 'package:flutter/foundation.dart';

/// Single shared source of truth for a Tourist's favorited/saved listing
/// ids — same `ChangeNotifier` singleton pattern as every other feature
/// controller. Local UI state only (matches this app's existing "lost on
/// restart" convention for everything else that has no persistence layer
/// yet); TODO marks the one place a real backend sync would plug in.
/// Deliberately keyed by `ProviderListing.id`, not the object itself, so
/// it never risks holding a stale copy of listing data.
class FavoritesController extends ChangeNotifier {
  FavoritesController._();

  static final FavoritesController instance = FavoritesController._();

  final Set<String> _favoriteListingIds = {};

  bool isFavorite(String listingId) => _favoriteListingIds.contains(listingId);

  void toggle(String listingId) {
    if (!_favoriteListingIds.remove(listingId)) {
      _favoriteListingIds.add(listingId);
    }
    notifyListeners();
    // TODO: persist favorite/unfavorite to a backend once one exists.
  }
}
