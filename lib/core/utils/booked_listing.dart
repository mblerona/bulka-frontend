import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/blocs/listings/listings_bloc.dart';
import 'package:bulka_frontend/blocs/public_listings/public_listings_bloc.dart';
import 'package:bulka_frontend/models/provider_listing.dart';

/// A reservation's listing: one of the sample listings, or a backend
/// listing the Tourist booked (see `PublicListing.toBookingListing`).
/// Reservations are still local, so they point at either.
ProviderListing? findBookedListing(BuildContext context, String listingId) {
  return context.read<ListingsBloc>().state.byId(listingId) ??
      context
          .read<PublicListingsBloc>()
          .state
          .byId(listingId)
          ?.toBookingListing();
}
