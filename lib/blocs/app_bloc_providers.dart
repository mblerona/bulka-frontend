import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/blocs/auth/auth_bloc.dart';
import 'package:bulka_frontend/blocs/availability/availability_bloc.dart';
import 'package:bulka_frontend/blocs/chat/chat_bloc.dart';
import 'package:bulka_frontend/blocs/favorites/favorites_bloc.dart';
import 'package:bulka_frontend/blocs/guest_ratings/guest_ratings_bloc.dart';
import 'package:bulka_frontend/blocs/listing_reviews/listing_reviews_bloc.dart';
import 'package:bulka_frontend/blocs/listings/listings_bloc.dart';
import 'package:bulka_frontend/blocs/locale/locale_bloc.dart';
import 'package:bulka_frontend/blocs/notifications/notifications_bloc.dart';
import 'package:bulka_frontend/blocs/reservations/reservations_bloc.dart';
import 'package:bulka_frontend/blocs/search/search_bloc.dart';
import 'package:bulka_frontend/blocs/support_tickets/support_tickets_bloc.dart';
import 'package:bulka_frontend/core/network/api_client.dart';

/// Creates every app-wide bloc, once, above the router — so every screen
/// and route builder can `context.read`/`context.watch` them. Each
/// `BulkaApp` (and each test) gets fresh blocs.
class AppBlocProviders extends StatelessWidget {
  const AppBlocProviders({
    super.key,
    required this.initialLocale,
    required this.child,
  });

  /// From [LocaleBloc.loadInitialLocale].
  final Locale initialLocale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocaleBloc(initialLocale: initialLocale)),
        BlocProvider(
          // Created right away so the API client can report an expired
          // session even before any screen has read it.
          lazy: false,
          create: (_) {
            final bloc = AuthBloc();
            ApiClient.instance.onSessionExpired = () =>
                bloc.add(const AuthSessionExpired());
            return bloc;
          },
        ),
        BlocProvider(create: (_) => ListingsBloc()),
        BlocProvider(create: (_) => ReservationsBloc()),
        BlocProvider(create: (_) => ListingReviewsBloc()),
        BlocProvider(create: (_) => GuestRatingsBloc()),
        BlocProvider(create: (_) => AvailabilityBloc()),
        BlocProvider(create: (_) => SearchBloc()),
        BlocProvider(create: (_) => ChatBloc()),
        BlocProvider(create: (_) => FavoritesBloc()),
        BlocProvider(create: (_) => NotificationsBloc()),
        BlocProvider(create: (_) => SupportTicketsBloc()),
      ],
      child: child,
    );
  }
}
