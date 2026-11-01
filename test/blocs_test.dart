import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bulka_frontend/blocs/auth/auth_bloc.dart';
import 'package:bulka_frontend/blocs/availability/availability_bloc.dart';
import 'package:bulka_frontend/blocs/chat/chat_bloc.dart';
import 'package:bulka_frontend/blocs/favorites/favorites_bloc.dart';
import 'package:bulka_frontend/blocs/guest_ratings/guest_ratings_bloc.dart';
import 'package:bulka_frontend/blocs/listing_reviews/listing_reviews_bloc.dart';
import 'package:bulka_frontend/blocs/listings/listings_bloc.dart';
import 'package:bulka_frontend/blocs/reservations/reservations_bloc.dart';
import 'package:bulka_frontend/blocs/search/search_bloc.dart';
import 'package:bulka_frontend/core/network/api_exception.dart';
import 'package:bulka_frontend/core/network/token_storage.dart';
import 'package:bulka_frontend/models/auth_user.dart';
import 'package:bulka_frontend/models/availability_status.dart';
import 'package:bulka_frontend/models/chat_conversation.dart';
import 'package:bulka_frontend/models/chat_message.dart';
import 'package:bulka_frontend/models/listing_category.dart';
import 'package:bulka_frontend/models/listing_search_filter.dart';
import 'package:bulka_frontend/models/provider_listing.dart';
import 'package:bulka_frontend/models/reservation.dart';
import 'package:bulka_frontend/models/user_role.dart';

ProviderListing _listing({
  String id = 'l1',
  String title = 'Куќа',
  double price = 1000,
  ListingCategory? category = ListingCategory.accommodation,
  ListingStatus status = ListingStatus.active,
}) => ProviderListing(
  id: id,
  title: title,
  status: status,
  location: 'Охрид',
  updatedAt: DateTime(2026),
  price: price,
  category: category,
  guestCapacity: 4,
);

Reservation _reservation({
  String id = 'r1',
  ReservationStatus status = ReservationStatus.completed,
  String listingName = 'Куќа',
  DateTime? start,
  DateTime? end,
}) => Reservation(
  id: id,
  guestName: 'Гостин',
  listingName: listingName,
  listingId: 'l1',
  startDate: start ?? DateTime(2026, 8, 10),
  endDate: end ?? DateTime(2026, 8, 13),
  guestCount: 2,
  status: status,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  group('ReservationsBloc', () {
    blocTest<ReservationsBloc, ReservationsState>(
      'a booking is pending, prices are fixed, and it is lastCreated',
      build: () => ReservationsBloc(initialReservations: const []),
      act: (bloc) => bloc.add(
        ReservationRequested(
          listing: _listing(price: 1000),
          guestName: 'Ана',
          startDate: DateTime(2026, 9, 1),
          endDate: DateTime(2026, 9, 4),
          guestCount: 2,
        ),
      ),
      verify: (bloc) {
        final created = bloc.state.lastCreated!;
        expect(bloc.state.reservations, [created]);
        expect(created.status, ReservationStatus.pending);
        expect(created.nightlyPriceAtBooking, 1000);
        expect(created.totalAmount, 3000 + created.serviceFee!);
        expect(created.bookingReference, startsWith('RB-'));
      },
    );

    blocTest<ReservationsBloc, ReservationsState>(
      'accepting changes only that reservation',
      build: () => ReservationsBloc(
        initialReservations: [
          _reservation(id: 'a', status: ReservationStatus.pending),
          _reservation(id: 'b', status: ReservationStatus.pending),
        ],
      ),
      act: (bloc) => bloc.add(const ReservationAccepted('a')),
      verify: (bloc) {
        expect(bloc.state.byId('a')!.status, ReservationStatus.accepted);
        expect(bloc.state.byId('b')!.status, ReservationStatus.pending);
        expect(bloc.state.pending.map((r) => r.id), ['b']);
      },
    );
  });

  group('ListingsBloc', () {
    blocTest<ListingsBloc, ListingsState>(
      'reactivating makes a listing active again',
      build: () => ListingsBloc(
        initialListings: [_listing(status: ListingStatus.archived)],
      ),
      act: (bloc) => bloc.add(const ListingReactivated('l1')),
      verify: (bloc) => expect(bloc.state.activeCount, 1),
    );

    blocTest<ListingsBloc, ListingsState>(
      'an unknown id changes nothing',
      build: () => ListingsBloc(initialListings: [_listing()]),
      act: (bloc) => bloc.add(const ListingReactivated('nope')),
      expect: () => isEmpty,
    );
  });

  group('ListingReviewsBloc', () {
    ListingReviewSubmitted review(Reservation reservation, {int rating = 5}) =>
        ListingReviewSubmitted(
          listing: _listing(),
          reservation: reservation,
          authorName: 'Ана',
          rating: rating,
          comment: '  Одлично  ',
        );

    blocTest<ListingReviewsBloc, ListingReviewsState>(
      'one review per completed reservation, comment trimmed',
      build: () => ListingReviewsBloc(initialReviews: const []),
      act: (bloc) => bloc
        ..add(review(_reservation()))
        ..add(review(_reservation(), rating: 1)),
      verify: (bloc) {
        expect(bloc.state.reviews, hasLength(1));
        expect(bloc.state.reviews.single.comment, 'Одлично');
        expect(bloc.state.effectiveRating(_listing()), 5);
      },
    );

    blocTest<ListingReviewsBloc, ListingReviewsState>(
      'ignores stays that are not completed and invalid ratings',
      build: () => ListingReviewsBloc(initialReviews: const []),
      act: (bloc) => bloc
        ..add(review(_reservation(status: ReservationStatus.accepted)))
        ..add(review(_reservation(), rating: 6)),
      expect: () => isEmpty,
    );
  });

  group('GuestRatingsBloc', () {
    blocTest<GuestRatingsBloc, GuestRatingsState>(
      'one rating per completed reservation; empty note becomes null',
      build: GuestRatingsBloc.new,
      act: (bloc) => bloc
        ..add(
          GuestRatingSubmitted(
            reservation: _reservation(),
            rating: 4,
            note: ' ',
          ),
        )
        ..add(GuestRatingSubmitted(reservation: _reservation(), rating: 2)),
      verify: (bloc) {
        expect(bloc.state.ratings, hasLength(1));
        expect(bloc.state.forReservation('r1')!.note, isNull);
        expect(bloc.state.hasRating('r1'), isTrue);
      },
    );
  });

  group('ChatBloc', () {
    ChatConversation conversation() => ChatConversation(
      id: 'c1',
      participantName: 'Стефан',
      avatarInitials: 'С',
      messages: [
        ChatMessage(
          id: 'm1',
          conversationId: 'c1',
          text: 'Здраво',
          timestamp: DateTime(2026),
          isMine: false,
        ),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'opening a conversation clears its unread count',
      build: () => ChatBloc(initialConversations: [conversation()]),
      act: (bloc) => bloc.add(const ConversationRead('c1')),
      verify: (bloc) => expect(bloc.state.totalUnreadMessages, 0),
    );

    blocTest<ChatBloc, ChatState>(
      'sending appends a trimmed message; blank text is ignored',
      build: () => ChatBloc(initialConversations: [conversation()]),
      act: (bloc) => bloc
        ..add(const ChatMessageSent(conversationId: 'c1', text: '  Да  '))
        ..add(const ChatMessageSent(conversationId: 'c1', text: '   ')),
      verify: (bloc) {
        final messages = bloc.state.byId('c1')!.messages;
        expect(messages, hasLength(2));
        expect(messages.last.text, 'Да');
        expect(messages.last.isMine, isTrue);
      },
    );
  });

  blocTest<FavoritesBloc, FavoritesState>(
    'toggling twice adds then removes a favourite',
    build: FavoritesBloc.new,
    act: (bloc) => bloc
      ..add(const FavoriteToggled('l1'))
      ..add(const FavoriteToggled('l1')),
    verify: (bloc) => expect(bloc.state.isFavorite('l1'), isFalse),
  );

  group('AvailabilityBloc', () {
    final listings = ListingsState([_listing(id: '1', title: 'Куќа')]);
    final reservations = ReservationsState([
      _reservation(
        status: ReservationStatus.accepted,
        start: DateTime(2026, 9, 10),
        end: DateTime(2026, 9, 12),
      ),
    ]);

    blocTest<AvailabilityBloc, AvailabilityState>(
      'block and unblock dates; accepted bookings show as occupied',
      build: AvailabilityBloc.new,
      act: (bloc) => bloc
        ..add(DatesBlocked(listingId: '1', dates: {DateTime(2026, 9, 1, 15)}))
        ..add(DatesUnblocked(listingId: '1', dates: {DateTime(2026, 8, 5)})),
      verify: (bloc) {
        AvailabilityStatus status(DateTime d) => bloc.state.statusFor(
          '1',
          d,
          listings: listings,
          reservations: reservations,
        );
        expect(status(DateTime(2026, 9, 1)), AvailabilityStatus.blocked);
        expect(status(DateTime(2026, 8, 5)), AvailabilityStatus.available);
        expect(status(DateTime(2026, 9, 11)), AvailabilityStatus.occupied);
        // The check-out day is free again.
        expect(status(DateTime(2026, 9, 12)), AvailabilityStatus.available);
      },
    );
  });

  test('searchListings filters active listings by category and price', () {
    final listings = ListingsState([
      _listing(id: 'cheap', price: 500),
      _listing(id: 'pricey', price: 5000),
      _listing(id: 'food', category: ListingCategory.gastronomy),
      _listing(id: 'archived', status: ListingStatus.archived),
    ]);
    final filter = ListingSearchFilter()
      ..categories = {ListingCategory.accommodation}
      ..maxPrice = 1000;
    final matches = searchListings(
      filter: filter,
      listings: listings,
      reviews: ListingReviewsState(const []),
    );
    expect(matches.map((l) => l.id), ['cheap']);
  });

  group('AuthBloc', () {
    late _FakeTokenStorage tokens;
    setUp(() => tokens = _FakeTokenStorage());

    AuthBloc authWith(Map<String, (int, Object)> responses) {
      final dio = Dio(BaseOptions(baseUrl: 'https://test'))
        ..httpClientAdapter = _FakeAdapter(responses);
      return AuthBloc(dio: dio, tokenStorage: tokens);
    }

    const userJson = {
      'id': 'u1',
      'email': 'ana@example.com',
      'roles': ['Provider'],
    };

    blocTest<AuthBloc, AuthState>(
      'login stores the tokens and signs the user in',
      // The handlers await the (fake) HTTP request.
      wait: const Duration(milliseconds: 50),
      build: () => authWith({
        '/api/auth/login': (
          200,
          {
            'success': true,
            'data': {
              'accessToken': 'access',
              'refreshToken': 'refresh',
              'user': userJson,
            },
          },
        ),
      }),
      act: (bloc) => bloc.add(
        const AuthLoginRequested(email: ' ana@example.com ', password: 'pw'),
      ),
      verify: (bloc) {
        expect(bloc.state.status, AuthOperationStatus.succeeded);
        expect(bloc.state.user!.role, UserRole.owner);
        expect(tokens.access, 'access');
        expect(tokens.refresh, 'refresh');
      },
    );

    blocTest<AuthBloc, AuthState>(
      'admin accounts are refused and their tokens are not stored',
      // The handlers await the (fake) HTTP request.
      wait: const Duration(milliseconds: 50),
      build: () => authWith({
        '/api/auth/login': (
          200,
          {
            'success': true,
            'data': {
              'accessToken': 'access',
              'refreshToken': 'refresh',
              'user': {
                'id': 'a1',
                'email': 'admin@example.com',
                'roles': ['Admin'],
              },
            },
          },
        ),
        '/api/auth/logout': (200, {'success': true}),
      }),
      act: (bloc) => bloc.add(
        const AuthLoginRequested(email: 'admin@example.com', password: 'pw'),
      ),
      verify: (bloc) {
        expect(bloc.state.status, AuthOperationStatus.failed);
        expect(bloc.state.isLoggedIn, isFalse);
        expect(tokens.access, isNull);
        expect(tokens.refresh, isNull);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'a saved admin session is not restored',
      // The handlers await the (fake) HTTP request.
      wait: const Duration(milliseconds: 50),
      build: () => authWith({
        '/api/users/me': (
          200,
          {
            'success': true,
            'data': {
              'id': 'a1',
              'email': 'admin@example.com',
              'roles': ['Admin'],
            },
          },
        ),
        '/api/auth/logout': (200, {'success': true}),
      }),
      setUp: () {
        tokens.access = 'access';
        tokens.refresh = 'refresh';
      },
      act: (bloc) => bloc.add(const AuthSessionRestoreRequested()),
      verify: (bloc) {
        expect(bloc.state.status, AuthOperationStatus.failed);
        expect(bloc.state.isLoggedIn, isFalse);
        expect(tokens.refresh, isNull);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'wrong credentials fail with an unauthorized error',
      // The handlers await the (fake) HTTP request.
      wait: const Duration(milliseconds: 50),
      build: () => authWith({
        '/api/auth/login': (
          401,
          {
            'success': false,
            'errors': [
              {'code': 'AUTH_INVALID_CREDENTIALS', 'message': 'Invalid.'},
            ],
          },
        ),
      }),
      act: (bloc) =>
          bloc.add(const AuthLoginRequested(email: 'a@b.c', password: 'x')),
      verify: (bloc) {
        expect(bloc.state.operation, AuthOperation.login);
        expect(bloc.state.status, AuthOperationStatus.failed);
        expect(bloc.state.error!.kind, ApiErrorKind.unauthorized);
        expect(bloc.state.isLoggedIn, isFalse);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'registration reports whether email verification is needed',
      // The handlers await the (fake) HTTP request.
      wait: const Duration(milliseconds: 50),
      build: () => authWith({
        '/api/auth/register/buyer': (
          200,
          {
            'success': true,
            'data': {'userId': 'u2', 'emailVerificationRequired': true},
          },
        ),
      }),
      act: (bloc) => bloc.add(
        const AuthRegistrationRequested(
          role: UserRole.buyer,
          firstName: 'Ана',
          lastName: 'Трајковска',
          email: 'ana@example.com',
          phone: '+38970123456',
          password: 'Secret1!',
        ),
      ),
      verify: (bloc) {
        expect(bloc.state.status, AuthOperationStatus.succeeded);
        expect(bloc.state.emailVerificationRequired, isTrue);
        expect(bloc.state.isLoggedIn, isFalse);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'restoring a saved session loads the user',
      // The handlers await the (fake) HTTP request.
      wait: const Duration(milliseconds: 50),
      build: () => authWith({
        '/api/users/me': (200, {'success': true, 'data': userJson}),
      }),
      setUp: () {
        tokens.access = 'access';
        tokens.refresh = 'refresh';
      },
      act: (bloc) => bloc.add(const AuthSessionRestoreRequested()),
      verify: (bloc) {
        expect(bloc.state.status, AuthOperationStatus.succeeded);
        expect(bloc.state.user!.role, UserRole.owner);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'restoring without saved tokens fails without a request',
      build: () => authWith({}),
      act: (bloc) => bloc.add(const AuthSessionRestoreRequested()),
      verify: (bloc) {
        expect(bloc.state.operation, AuthOperation.restoreSession);
        expect(bloc.state.status, AuthOperationStatus.failed);
        expect(bloc.state.isLoggedIn, isFalse);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'forgot password and reset password succeed',
      // The handlers await the (fake) HTTP request.
      wait: const Duration(milliseconds: 50),
      build: () => authWith({
        '/api/auth/forgot-password': (200, {'success': true}),
        '/api/auth/reset-password': (200, {'success': true}),
      }),
      act: (bloc) async {
        bloc.add(const AuthPasswordResetCodeRequested('ana@example.com'));
        await Future<void>.delayed(const Duration(milliseconds: 20));
        expect(bloc.state.operation, AuthOperation.requestPasswordReset);
        expect(bloc.state.status, AuthOperationStatus.succeeded);
        bloc.add(
          const AuthPasswordResetRequested(
            email: 'ana@example.com',
            code: '123456',
            newPassword: 'Secret1!',
          ),
        );
      },
      verify: (bloc) {
        expect(bloc.state.operation, AuthOperation.resetPassword);
        expect(bloc.state.status, AuthOperationStatus.succeeded);
        expect(bloc.state.isLoggedIn, isFalse);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'an unverified email is reported by its error code',
      // The handlers await the (fake) HTTP request.
      wait: const Duration(milliseconds: 50),
      build: () => authWith({
        '/api/auth/login': (
          403,
          {
            'success': false,
            'errors': [
              {'code': 'AUTH_EMAIL_NOT_VERIFIED', 'message': 'Not verified.'},
            ],
          },
        ),
      }),
      act: (bloc) =>
          bloc.add(const AuthLoginRequested(email: 'a@b.c', password: 'x')),
      verify: (bloc) {
        expect(bloc.state.status, AuthOperationStatus.failed);
        expect(
          bloc.state.error!.hasErrorCode('AUTH_EMAIL_NOT_VERIFIED'),
          isTrue,
        );
      },
    );

    blocTest<AuthBloc, AuthState>(
      'logout clears the user and the tokens, even if the request fails',
      // The handlers await the (fake) HTTP request.
      wait: const Duration(milliseconds: 50),
      build: () => authWith({}),
      seed: () => AuthState(user: _user()),
      setUp: () => tokens.refresh = 'refresh',
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      verify: (bloc) {
        expect(bloc.state.isLoggedIn, isFalse);
        expect(tokens.refresh, isNull);
      },
    );
  });
}

AuthUser _user() => AuthUser.fromJson(const {
  'id': 'u1',
  'email': 'ana@example.com',
  'roles': ['Buyer'],
});

class _FakeTokenStorage implements TokenStorage {
  String? access;
  String? refresh;

  @override
  Future<String?> readAccessToken() async => access;

  @override
  Future<String?> readRefreshToken() async => refresh;

  @override
  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    access = accessToken;
    refresh = refreshToken;
  }

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
  }
}

/// Answers each path with a fixed (status, JSON body); unknown paths 500.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.responses);

  final Map<String, (int, Object)> responses;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final (status, body) = responses[options.path] ?? (500, const {});
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
