import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bulka_frontend/blocs/amenities/amenities_bloc.dart';
import 'package:bulka_frontend/blocs/auth/auth_bloc.dart';
import 'package:bulka_frontend/blocs/availability/availability_bloc.dart';
import 'package:bulka_frontend/blocs/categories/categories_bloc.dart';
import 'package:bulka_frontend/blocs/chat/chat_bloc.dart';
import 'package:bulka_frontend/blocs/favorites/favorites_bloc.dart';
import 'package:bulka_frontend/blocs/guest_ratings/guest_ratings_bloc.dart';
import 'package:bulka_frontend/blocs/listing_reviews/listing_reviews_bloc.dart';
import 'package:bulka_frontend/blocs/listings/listings_bloc.dart';
import 'package:bulka_frontend/blocs/notifications/notifications_bloc.dart';
import 'package:bulka_frontend/blocs/public_listings/public_listings_bloc.dart';
import 'package:bulka_frontend/blocs/reservations/reservations_bloc.dart';
import 'package:bulka_frontend/blocs/support_tickets/support_tickets_bloc.dart';
import 'package:bulka_frontend/core/network/api_exception.dart';
import 'package:bulka_frontend/core/network/token_storage.dart';
import 'package:bulka_frontend/models/auth_user.dart';
import 'package:bulka_frontend/models/availability_status.dart';
import 'package:bulka_frontend/models/chat_conversation.dart';
import 'package:bulka_frontend/models/chat_message.dart';
import 'package:bulka_frontend/models/listing_amenity.dart';
import 'package:bulka_frontend/models/listing_category.dart';
import 'package:bulka_frontend/models/listing_search_filter.dart';
import 'package:bulka_frontend/models/notification_item.dart';
import 'package:bulka_frontend/models/provider_listing.dart';
import 'package:bulka_frontend/models/reservation.dart';
import 'package:bulka_frontend/models/support_attachment.dart';
import 'package:bulka_frontend/models/support_ticket.dart';
import 'package:bulka_frontend/models/user_role.dart';

ProviderListing _listing({
  String id = 'l1',
  String title = 'Куќа',
  double price = 1000,
  ListingCategory? category = ListingCategory.accommodation,
  ListingStatus status = ListingStatus.active,
  Set<ListingAmenity> amenities = const {},
}) => ProviderListing(
  id: id,
  title: title,
  status: status,
  location: 'Охрид',
  updatedAt: DateTime(2026),
  price: price,
  category: category,
  guestCapacity: 4,
  amenities: amenities,
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

  group('listingSearchQuery', () {
    test('an empty filter sends only paging (and the currency)', () {
      expect(listingSearchQuery(ListingSearchFilter(), page: 2, pageSize: 20), {
        'currencyCode': 'MKD',
        'sort': 'newest',
        'page': 2,
        'pageSize': 20,
      });
    });

    test('sends each set filter under the backend\'s name', () {
      final filter = ListingSearchFilter()
        ..keyword = '  rancho '
        ..regionId = 'r1'
        ..categoryId = 'c1'
        ..amenityIds = {'a7', 'a1'}
        ..maxPrice = 5000
        ..minRating = 4.5
        ..minimumGuests = 3
        ..startDate = DateTime(2026, 11, 10)
        ..endDate = DateTime(2026, 11, 12);
      final query = listingSearchQuery(filter, page: 1, pageSize: 20);
      expect(query['q'], 'rancho');
      expect(query['regionId'], 'r1');
      expect(query['categoryId'], 'c1');
      expect(query['amenityIds'], 'a1,a7');
      // Both ends are sent once either is set.
      expect(query['minPrice'], 0);
      expect(query['maxPrice'], 5000);
      // The backend takes whole stars.
      expect(query['minRating'], 4);
      expect(query['guests'], 3);
      expect(
        query['availabilityFromUtc'],
        DateTime(2026, 11, 10).toUtc().toIso8601String(),
      );
      expect(
        query['availabilityToUtc'],
        DateTime(2026, 11, 12, 23, 59, 59, 999).toUtc().toIso8601String(),
      );
    });
  });

  group('PublicListingsBloc', () {
    Map<String, Object?> searchItem(
      String id, {
      double? rating,
      String? cover,
    }) => {
      'id': id,
      'slug': 'slug-$id',
      'title': 'Listing $id',
      'municipalityName': 'Струмица',
      'settlementName': 'Габрово',
      'coverImageUrl': cover,
      'priceAmount': null,
      'ratingSummary': {'averageRating': rating, 'reviewCount': 1},
      'categories': [],
      'amenities': [],
    };

    Map<String, Object> page(
      List<Map<String, Object?>> items, {
      int page = 1,
      int totalPages = 1,
      int? total,
    }) => {
      'success': true,
      'data': {
        'items': items,
        'page': page,
        'pageSize': 20,
        'totalCount': total ?? items.length,
        'totalPages': totalPages,
      },
    };

    late _FakeAdapter adapter;
    PublicListingsBloc listingsWith(Map<String, (int, Object)> responses) {
      adapter = _FakeAdapter(responses);
      return PublicListingsBloc(
        dio: Dio(BaseOptions(baseUrl: 'https://test'))
          ..httpClientAdapter = adapter,
      );
    }

    blocTest<PublicListingsBloc, PublicListingsState>(
      'loads the recommended (newest) listings',
      build: () => listingsWith({
        '/api/listings': (
          200,
          page([searchItem('1', cover: '/media/a.jpg'), searchItem('2')]),
        ),
      }),
      act: (bloc) => bloc.add(const RecommendedListingsRequested('mk')),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        final state = bloc.state;
        expect(state.recommendedStatus, ListingsLoadStatus.loaded);
        expect(state.recommended.map((l) => l.slug), ['slug-1', 'slug-2']);
        final first = state.recommended.first;
        expect(first.location, 'Габрово, Струмица');
        // Uploaded images come as paths on the API server.
        expect(first.coverImageUrl, endsWith('/media/a.jpg'));
        expect(first.coverImageUrl, startsWith('http'));
        expect(adapter.requests.single.queryParameters['pageSize'], 6);
        expect(state.needsRecommendedFor('mk'), isFalse);
        expect(state.needsRecommendedFor('en'), isTrue);
      },
    );

    blocTest<PublicListingsBloc, PublicListingsState>(
      'searches with the filter, then loads more pages',
      build: () => listingsWith({
        '/api/listings': (
          200,
          page([searchItem('1')], totalPages: 2, total: 2),
        ),
      }),
      act: (bloc) async {
        bloc.add(
          ListingSearchRequested(
            ListingSearchFilter()..categoryId = 'c1',
            'mk',
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 30));
        // Page 2 has a new listing.
        adapter.responses['/api/listings'] = (
          200,
          page([searchItem('2')], page: 2, totalPages: 2, total: 2),
        );
        bloc.add(const MoreSearchResultsRequested());
      },
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        final state = bloc.state;
        expect(state.resultsStatus, ListingsLoadStatus.loaded);
        expect(state.results.map((l) => l.id), ['1', '2']);
        expect(state.resultsTotal, 2);
        expect(state.resultsHasMore, isFalse);
        expect(adapter.requests.first.queryParameters['categoryId'], 'c1');
        expect(adapter.requests.last.queryParameters['page'], 2);
        expect(
          state.needsResultsFor(
            searchKey(ListingSearchFilter()..categoryId = 'c1', 'mk'),
          ),
          isFalse,
        );
      },
    );

    blocTest<PublicListingsBloc, PublicListingsState>(
      '"4.5+" also drops listings rated 4.0–4.4 (the backend takes 4)',
      build: () => listingsWith({
        '/api/listings': (
          200,
          page([searchItem('1', rating: 4.8), searchItem('2', rating: 4.2)]),
        ),
      }),
      act: (bloc) => bloc.add(
        ListingSearchRequested(ListingSearchFilter()..minRating = 4.5, 'mk'),
      ),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.results.map((l) => l.id), ['1']);
        expect(bloc.state.resultsTotal, 1);
      },
    );

    blocTest<PublicListingsBloc, PublicListingsState>(
      'a failed search ends in failed',
      build: () => listingsWith({}),
      act: (bloc) =>
          bloc.add(ListingSearchRequested(ListingSearchFilter(), 'mk')),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) =>
          expect(bloc.state.resultsStatus, ListingsLoadStatus.failed),
    );

    blocTest<PublicListingsBloc, PublicListingsState>(
      'loads details with item prices; only nightly items are bookable',
      build: () => listingsWith({
        '/api/listings/stay': (
          200,
          {
            'success': true,
            'data': {
              ...searchItem('9'),
              'slug': 'stay',
              'description': 'Опис',
              'mode': 'Itemized',
              'provider': {'businessName': 'Домаќин'},
              'images': [
                {'publicUrl': 'https://img/2.jpg', 'sortOrder': 2},
                {
                  'publicUrl': 'https://img/1.jpg',
                  'sortOrder': 1,
                  'isCover': true,
                },
              ],
            },
          },
        ),
        '/api/itemized-listings/stay': (
          200,
          {
            'success': true,
            'data': {
              'items': [
                {
                  'id': 'tour',
                  'kind': 'Experience',
                  'title': 'Тура',
                  'experience': {'priceAmount': 800, 'capacity': 4},
                },
                {
                  'id': 'room',
                  'kind': 'Accommodation',
                  'title': 'Соба',
                  'accommodation': {
                    'nightlyPriceAmount': 1500,
                    'priceBasis': 'PerPerson',
                    'guestCapacity': 3,
                  },
                },
              ],
            },
          },
        ),
      }),
      act: (bloc) => bloc.add(const ListingDetailsRequested('stay', 'mk')),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        final listing = bloc.state.detailsFor('stay')!;
        expect(bloc.state.detailsStatusFor('stay'), ListingsLoadStatus.loaded);
        expect(listing.providerName, 'Домаќин');
        expect(listing.imageUrls, ['https://img/1.jpg', 'https://img/2.jpg']);
        expect(listing.items.map((i) => i.id), ['tour', 'room']);
        expect(listing.lowestItemPrice, 800);
        expect(listing.bookableItem?.id, 'room');
        expect(listing.bookableItem?.perPerson, isTrue);

        final booking = listing.toBookingListing()!;
        expect(booking.id, '9');
        expect(booking.price, 1500);
        expect(booking.guestCapacity, 3);
        // Reservations can find it by id.
        expect(bloc.state.byId('9')?.slug, 'stay');
      },
    );

    blocTest<PublicListingsBloc, PublicListingsState>(
      'an unknown slug ends in notFound',
      build: () => listingsWith({
        '/api/listings/nope': (
          404,
          {
            'success': false,
            'errors': [
              {'code': 'PUBLIC_LISTING_NOT_FOUND'},
            ],
          },
        ),
      }),
      act: (bloc) => bloc.add(const ListingDetailsRequested('nope', 'mk')),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) => expect(
        bloc.state.detailsStatusFor('nope'),
        ListingsLoadStatus.notFound,
      ),
    );
  });

  group('SupportTicketsBloc', () {
    SupportTicketsBloc ticketsWith((int, Object) response) {
      return SupportTicketsBloc(
        dio: Dio(BaseOptions(baseUrl: 'https://test'))
          ..httpClientAdapter = _FakeAdapter({'/api/me/tickets': response}),
      );
    }

    const older = {
      'id': '11111111-1111-1111-1111-111111111111',
      'ticketNumber': 'TCK-1',
      'type': 'Payment',
      'status': 'Closed',
      'subject': 'Older',
      'createdAtUtc': '2026-01-01T10:00:00Z',
      'closedAtUtc': '2026-01-03T10:00:00Z',
    };
    const newer = {
      'id': '22222222-2222-2222-2222-222222222222',
      'ticketNumber': 'TCK-2',
      'type': 'Technical',
      'status': 'InProgress',
      'subject': 'Newer',
      'createdAtUtc': '2026-02-01T10:00:00Z',
    };

    blocTest<SupportTicketsBloc, SupportTicketsState>(
      'loads the tickets, newest first',
      build: () => ticketsWith((
        200,
        {
          'success': true,
          'data': [older, newer],
        },
      )),
      act: (bloc) => bloc.add(const SupportTicketsRequested()),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        isA<SupportTicketsState>().having(
          (s) => s.status,
          'status',
          SupportTicketsStatus.loading,
        ),
        isA<SupportTicketsState>().having(
          (s) => s.status,
          'status',
          SupportTicketsStatus.loaded,
        ),
      ],
      verify: (bloc) {
        final tickets = bloc.state.tickets;
        expect(tickets.map((t) => t.number), ['TCK-2', 'TCK-1']);
        expect(tickets.first.title, 'Newer');
        expect(tickets.first.status, TicketStatus.inProgress);
        expect(tickets.first.updatedAt, tickets.first.createdAt);
        expect(tickets.last.status, TicketStatus.closed);
        expect(tickets.last.updatedAt, DateTime.utc(2026, 1, 3, 10));
      },
    );

    blocTest<SupportTicketsBloc, SupportTicketsState>(
      'reads a ticket as the backend sends it',
      build: () => ticketsWith((
        200,
        {
          'success': true,
          'data': [
            {
              'id': '9ffeb922-7c9c-4c15-9672-239849966ba6',
              'ticketNumber': 'HD-20260826190835-9486',
              'type': 'Other',
              'status': 'Closed',
              'priority': 'Normal',
              'subject': 'asdf',
              'description': 'asdfasdfsafsdafasdfasdf',
              'createdAtUtc': '2026-08-26T19:08:35.015267+00:00',
              'closedAtUtc': '2026-09-15T07:53:40.036639+00:00',
              'assignedTo': null,
              'attachments': <Object>[],
              'messages': [
                {'createdAtUtc': '2026-08-26T19:08:35.015267+00:00'},
                {'createdAtUtc': '2026-09-15T07:51:26.750158+00:00'},
              ],
            },
          ],
          'errors': <Object>[],
          'traceId': null,
        },
      )),
      act: (bloc) => bloc.add(const SupportTicketsRequested()),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.status, SupportTicketsStatus.loaded);
        final ticket = bloc.state.tickets.single;
        expect(ticket.number, 'HD-20260826190835-9486');
        expect(ticket.title, 'asdf');
        expect(ticket.description, 'asdfasdfsafsdafasdfasdf');
        expect(ticket.status, TicketStatus.closed);
        expect(ticket.createdAt, DateTime.utc(2026, 8, 26, 19, 8, 35, 15, 267));
        expect(ticket.updatedAt, DateTime.utc(2026, 9, 15, 7, 53, 40, 36, 639));
      },
    );

    blocTest<SupportTicketsBloc, SupportTicketsState>(
      'a message after the last change counts as the last update',
      build: () => ticketsWith((
        200,
        {
          'success': true,
          'data': [
            {
              ...newer,
              'messages': [
                {'createdAtUtc': '2026-03-01T10:00:00Z'},
                {'createdAtUtc': '2026-02-15T10:00:00Z'},
              ],
            },
          ],
        },
      )),
      act: (bloc) => bloc.add(const SupportTicketsRequested()),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(
          bloc.state.tickets.single.updatedAt,
          DateTime.utc(2026, 3, 1, 10),
        );
      },
    );

    blocTest<SupportTicketsBloc, SupportTicketsState>(
      'data that isn\'t a list ends in failed',
      build: () =>
          ticketsWith((200, {'success': true, 'data': <String, Object>{}})),
      act: (bloc) => bloc.add(const SupportTicketsRequested()),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.status, SupportTicketsStatus.failed);
      },
    );

    blocTest<SupportTicketsBloc, SupportTicketsState>(
      'a failed request ends in failed',
      build: () => ticketsWith((401, const {'success': false})),
      act: (bloc) => bloc.add(const SupportTicketsRequested()),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.status, SupportTicketsStatus.failed);
        expect(bloc.state.tickets, isEmpty);
      },
    );

    blocTest<SupportTicketsBloc, SupportTicketsState>(
      'a reload drops the previous list straight away',
      build: () => ticketsWith((500, const {})),
      seed: () => SupportTicketsState(
        tickets: [SupportTicket.fromJson(older)],
        status: SupportTicketsStatus.loaded,
      ),
      act: (bloc) => bloc.add(const SupportTicketsRequested()),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        isA<SupportTicketsState>()
            .having((s) => s.status, 'status', SupportTicketsStatus.loading)
            .having((s) => s.tickets, 'tickets', isEmpty),
        isA<SupportTicketsState>()
            .having((s) => s.status, 'status', SupportTicketsStatus.failed)
            .having((s) => s.tickets, 'tickets', isEmpty),
      ],
    );

    const detailsId = 'b646d4c2-e887-4969-8f24-5c2c9824107d';
    const detailsPath = '/api/me/tickets/$detailsId';
    const details = {
      'id': detailsId,
      'ticketNumber': 'HD-20260821063731-3332',
      'type': 'Booking',
      'status': 'InProgress',
      'priority': 'High',
      'subject': 'E2E тикет',
      'description': 'Реална локална E2E проверка на кориснички тикет.',
      'createdAtUtc': '2026-08-21T06:37:31.405668+00:00',
      'closedAtUtc': null,
      'attachments': [
        {
          'id': 'm1',
          'originalFileName': 'screenshot.png',
          'contentType': 'image/png',
          'publicUrl': 'https://cdn.test/screenshot.png',
        },
        {'id': 'm2', 'fileName': 'invoice.pdf', 'url': '/media/invoice.pdf'},
      ],
      'messages': [
        {'createdAtUtc': '2026-08-21T06:37:31.405668+00:00'},
        {'createdAtUtc': '2026-08-21T06:37:32.267118+00:00'},
      ],
    };

    SupportTicketsBloc detailsWith((int, Object) response) {
      return SupportTicketsBloc(
        dio: Dio(BaseOptions(baseUrl: 'https://test'))
          ..httpClientAdapter = _FakeAdapter({detailsPath: response}),
      );
    }

    blocTest<SupportTicketsBloc, SupportTicketsState>(
      'loads one ticket\'s details with its attachments',
      build: () => detailsWith((200, {'success': true, 'data': details})),
      act: (bloc) => bloc.add(const SupportTicketDetailsRequested(detailsId)),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        isA<SupportTicketsState>().having(
          (s) => s.detailsStatusFor(detailsId),
          'detailsStatus',
          SupportTicketsStatus.loading,
        ),
        isA<SupportTicketsState>().having(
          (s) => s.detailsStatusFor(detailsId),
          'detailsStatus',
          SupportTicketsStatus.loaded,
        ),
      ],
      verify: (bloc) {
        final ticket = bloc.state.detailsFor(detailsId)!;
        expect(ticket.number, 'HD-20260821063731-3332');
        expect(ticket.category, 'Booking');
        expect(ticket.status, TicketStatus.inProgress);
        expect(
          ticket.updatedAt,
          DateTime.utc(2026, 8, 21, 6, 37, 32, 267, 118),
        );
        final [image, document] = ticket.attachments;
        expect(image.type, SupportAttachmentType.image);
        expect(image.fileName, 'screenshot.png');
        expect(image.url, 'https://cdn.test/screenshot.png');
        expect(document.type, SupportAttachmentType.document);
        expect(document.url, endsWith('/media/invoice.pdf'));
      },
    );

    blocTest<SupportTicketsBloc, SupportTicketsState>(
      'an unknown ticket ends in notFound',
      build: () => detailsWith((404, const {'success': false})),
      act: (bloc) => bloc.add(const SupportTicketDetailsRequested(detailsId)),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(
          bloc.state.detailsStatusFor(detailsId),
          SupportTicketsStatus.notFound,
        );
        expect(bloc.state.detailsFor(detailsId), isNull);
      },
    );

    blocTest<SupportTicketsBloc, SupportTicketsState>(
      'a failed reload keeps the details already shown',
      build: () => detailsWith((500, const {})),
      seed: () => SupportTicketsState(
        details: {detailsId: SupportTicket.fromJson(details)},
        detailsStatus: {detailsId: SupportTicketsStatus.loaded},
      ),
      act: (bloc) => bloc.add(const SupportTicketDetailsRequested(detailsId)),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(
          bloc.state.detailsStatusFor(detailsId),
          SupportTicketsStatus.failed,
        );
        expect(bloc.state.detailsFor(detailsId)?.title, 'E2E тикет');
      },
    );

    test('a ticket created on this device isn\'t requested', () async {
      final adapter = _FakeAdapter({});
      final bloc = SupportTicketsBloc(
        dio: Dio(BaseOptions(baseUrl: 'https://test'))
          ..httpClientAdapter = adapter,
      );
      bloc.add(
        const SupportTicketCreated(
          category: 'Other',
          title: 'Local',
          description: 'Only here',
        ),
      );
      await bloc.stream.first;
      final id = bloc.state.tickets.single.id;
      bloc.add(SupportTicketDetailsRequested(id));
      await bloc.stream.first;
      expect(adapter.requests, isEmpty);
      expect(bloc.state.detailsStatusFor(id), SupportTicketsStatus.loaded);
      expect(bloc.state.detailsFor(id)?.title, 'Local');
      await bloc.close();
    });
  });

  group('NotificationsBloc', () {
    NotificationsBloc notificationsWith((int, Object) response) {
      return NotificationsBloc(
        dio: Dio(BaseOptions(baseUrl: 'https://test'))
          ..httpClientAdapter = _FakeAdapter({
            '/api/me/notifications': response,
          }),
      );
    }

    const read = {
      'id': '85113d40-b944-44f8-84f0-c854565e7e81',
      'type': 'Booking',
      'title': 'Резервацијата е потврдена',
      'body':
          'Потврдена е резервацијата за Работилница за традиционално сирење.',
      'linkUrl': '/bookings/a3fbcd24-d96d-4aa9-96a3-2b831920b30f',
      'readAtUtc': '2026-10-06T11:27:22.047409+00:00',
      'dismissedAtUtc': null,
      'createdAtUtc': '2026-10-01T16:07:00.846648+00:00',
    };
    const unread = {
      'id': 'n2',
      'type': 'Message',
      'title': 'Нова порака',
      'body': 'Здраво!',
      'linkUrl': null,
      'readAtUtc': null,
      'dismissedAtUtc': null,
      'createdAtUtc': '2026-10-02T09:00:00Z',
    };
    final dismissed = {
      ...unread,
      'id': 'n3',
      'dismissedAtUtc': '2026-10-03T09:00:00Z',
    };

    blocTest<NotificationsBloc, NotificationsState>(
      'loads the notifications, newest first, without dismissed ones',
      build: () => notificationsWith((
        200,
        {
          'success': true,
          'data': [read, unread, dismissed],
          'errors': <Object>[],
          'traceId': null,
        },
      )),
      act: (bloc) => bloc.add(const NotificationsRequested()),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        isA<NotificationsState>().having(
          (s) => s.status,
          'status',
          NotificationsStatus.loading,
        ),
        isA<NotificationsState>().having(
          (s) => s.status,
          'status',
          NotificationsStatus.loaded,
        ),
      ],
      verify: (bloc) {
        final notifications = bloc.state.notifications;
        expect(notifications.map((n) => n.id), ['n2', read['id']]);
        expect(bloc.state.unreadCount, 1);
        final booking = notifications.last;
        expect(booking.title, 'Резервацијата е потврдена');
        expect(booking.message, read['body']);
        expect(booking.isRead, isTrue);
        expect(booking.type, 'Booking');
        expect(booking.linkUrl, read['linkUrl']);
        expect(
          booking.timestamp,
          DateTime.utc(2026, 10, 1, 16, 7, 0, 846, 648),
        );
      },
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'a failed request ends in failed',
      build: () => notificationsWith((401, const {'success': false})),
      act: (bloc) => bloc.add(const NotificationsRequested()),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.status, NotificationsStatus.failed);
        expect(bloc.state.notifications, isEmpty);
      },
    );

    test(
      'tapping an unread notification marks it read on the backend',
      () async {
        final adapter = _FakeAdapter({
          '/api/me/notifications/n2/read': (
            200,
            {
              'success': true,
              'data': {
                ...unread,
                'readAtUtc': '2026-10-06T11:27:22.047409+00:00',
              },
              'errors': <Object>[],
              'traceId': null,
            },
          ),
        });
        final bloc = NotificationsBloc(
          dio: Dio(BaseOptions(baseUrl: 'https://test'))
            ..httpClientAdapter = adapter,
        );
        bloc.emit(
          NotificationsState(
            notifications: [NotificationItem.fromJson(unread)],
            status: NotificationsStatus.loaded,
          ),
        );
        bloc.add(const NotificationRead('n2'));
        // Read straight away, before the backend answers.
        final shown = await bloc.stream.first;
        expect(shown.unreadCount, 0);
        await bloc.stream.first;
        expect(bloc.state.notifications.single.isRead, isTrue);
        expect(bloc.state.status, NotificationsStatus.loaded);
        final request = adapter.requests.single;
        expect(request.method, 'POST');
        expect(request.path, '/api/me/notifications/n2/read');
        await bloc.close();
      },
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'if the backend refuses, it shows as unread again',
      build: () => notificationsWith((500, const {})),
      seed: () => NotificationsState(
        notifications: [NotificationItem.fromJson(unread)],
        status: NotificationsStatus.loaded,
      ),
      act: (bloc) => bloc.add(const NotificationRead('n2')),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        isA<NotificationsState>().having((s) => s.unreadCount, 'unread', 0),
        isA<NotificationsState>().having((s) => s.unreadCount, 'unread', 1),
      ],
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'an already read notification isn\'t sent again',
      build: () => notificationsWith((500, const {})),
      seed: () => NotificationsState(
        notifications: [NotificationItem.fromJson(read)],
        status: NotificationsStatus.loaded,
      ),
      act: (bloc) => bloc.add(NotificationRead(read['id']!)),
      wait: const Duration(milliseconds: 50),
      expect: () => <Object>[],
    );
  });

  group('NotificationsBloc mark all as read', () {
    const readAllPath = '/api/me/notifications/read-all';
    const first = {
      'id': 'a',
      'title': 'A',
      'body': '',
      'readAtUtc': null,
      'createdAtUtc': '2026-10-02T09:00:00Z',
    };
    const second = {
      'id': 'b',
      'title': 'B',
      'body': '',
      'readAtUtc': '2026-10-02T10:00:00Z',
      'createdAtUtc': '2026-10-01T09:00:00Z',
    };
    final seeded = NotificationsState(
      notifications: [
        NotificationItem.fromJson(first),
        NotificationItem.fromJson(second),
      ],
      status: NotificationsStatus.loaded,
      serverUnreadCount: 1,
    );

    test('marks every notification read on the backend', () async {
      final adapter = _FakeAdapter({
        readAllPath: (
          200,
          {
            'success': true,
            'data': {'count': 1},
            'errors': <Object>[],
            'traceId': null,
          },
        ),
      });
      final bloc = NotificationsBloc(
        dio: Dio(BaseOptions(baseUrl: 'https://test'))
          ..httpClientAdapter = adapter,
      );
      bloc.emit(seeded);
      bloc.add(const AllNotificationsRead());
      final shown = await bloc.stream.first;
      expect(shown.notifications.every((n) => n.isRead), isTrue);
      expect(shown.unreadCount, 0);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.unreadCount, 0);
      final request = adapter.requests.single;
      expect(request.method, 'POST');
      expect(request.path, readAllPath);
      await bloc.close();
    });

    blocTest<NotificationsBloc, NotificationsState>(
      'if the backend refuses, the unread ones show as unread again',
      build: () => NotificationsBloc(
        dio: Dio(BaseOptions(baseUrl: 'https://test'))
          ..httpClientAdapter = _FakeAdapter({readAllPath: (500, const {})}),
      ),
      seed: () => seeded,
      act: (bloc) => bloc.add(const AllNotificationsRead()),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        isA<NotificationsState>().having((s) => s.unreadCount, 'unread', 0),
        isA<NotificationsState>().having((s) => s.unreadCount, 'unread', 1),
      ],
      verify: (bloc) {
        final [a, b] = bloc.state.notifications;
        expect(a.isRead, isFalse);
        expect(b.isRead, isTrue);
      },
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'nothing is sent when nothing is unread',
      build: () => NotificationsBloc(
        dio: Dio(BaseOptions(baseUrl: 'https://test'))
          ..httpClientAdapter = _FakeAdapter({}),
      ),
      seed: () => NotificationsState(
        notifications: [NotificationItem.fromJson(second)],
        status: NotificationsStatus.loaded,
        serverUnreadCount: 0,
      ),
      act: (bloc) => bloc.add(const AllNotificationsRead()),
      wait: const Duration(milliseconds: 50),
      expect: () => <Object>[],
    );
  });

  group('NotificationsBloc unread count', () {
    const countPath = '/api/me/notifications/unread-count';
    const listPath = '/api/me/notifications';
    const unread = {
      'id': 'n1',
      'title': 'Нова порака',
      'body': 'Здраво!',
      'readAtUtc': null,
      'createdAtUtc': '2026-10-02T09:00:00Z',
    };

    NotificationsBloc notificationsWith(Map<String, (int, Object)> responses) {
      return NotificationsBloc(
        dio: Dio(BaseOptions(baseUrl: 'https://test'))
          ..httpClientAdapter = _FakeAdapter(responses),
      );
    }

    blocTest<NotificationsBloc, NotificationsState>(
      'the backend\'s count is the unread count',
      build: () => notificationsWith({
        listPath: (
          200,
          {
            'success': true,
            'data': [unread],
          },
        ),
        countPath: (
          200,
          {
            'success': true,
            'data': {'count': 7},
            'errors': <Object>[],
            'traceId': null,
          },
        ),
      }),
      act: (bloc) => bloc
        ..add(const NotificationsRequested())
        ..add(const UnreadNotificationsCountRequested()),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.status, NotificationsStatus.loaded);
        expect(bloc.state.serverUnreadCount, 7);
        expect(bloc.state.unreadCount, 7);
      },
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'a failed count falls back to counting the list',
      build: () => notificationsWith({
        listPath: (
          200,
          {
            'success': true,
            'data': [unread],
          },
        ),
        countPath: (500, const {}),
      }),
      act: (bloc) => bloc
        ..add(const NotificationsRequested())
        ..add(const UnreadNotificationsCountRequested()),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.serverUnreadCount, isNull);
        expect(bloc.state.unreadCount, 1);
      },
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'reading a notification lowers the backend\'s count',
      build: () => notificationsWith({
        '/api/me/notifications/n1/read': (
          200,
          {
            'success': true,
            'data': {...unread, 'readAtUtc': '2026-10-06T11:27:22Z'},
          },
        ),
      }),
      wait: const Duration(milliseconds: 50),
      seed: () => NotificationsState(
        notifications: [NotificationItem.fromJson(unread)],
        status: NotificationsStatus.loaded,
        serverUnreadCount: 3,
      ),
      act: (bloc) => bloc.add(const NotificationRead('n1')),
      verify: (bloc) => expect(bloc.state.unreadCount, 2),
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'a list reload clears the count from before',
      build: () => notificationsWith({}),
      seed: () => NotificationsState(serverUnreadCount: 3),
      act: (bloc) => bloc.add(const NotificationsRequested()),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.status, NotificationsStatus.failed);
        expect(bloc.state.serverUnreadCount, isNull);
      },
    );
  });

  group('AmenitiesBloc', () {
    blocTest<AmenitiesBloc, AmenitiesState>(
      'loads the amenities in the requested language',
      build: () {
        final dio = Dio(BaseOptions(baseUrl: 'https://test'))
          ..httpClientAdapter = _FakeAdapter({
            '/api/amenities': (
              200,
              {
                'success': true,
                'data': [
                  {'id': 'a1', 'code': 'wi-fi', 'name': 'Wi-Fi'},
                  {'id': 'a2', 'code': 'new-thing', 'name': 'Ново'},
                ],
              },
            ),
          });
        return AmenitiesBloc(dio: dio);
      },
      act: (bloc) => bloc.add(const AmenitiesRequested('en')),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        isA<AmenitiesState>().having(
          (s) => s.status,
          'status',
          AmenitiesStatus.loading,
        ),
        isA<AmenitiesState>().having(
          (s) => s.status,
          'status',
          AmenitiesStatus.loaded,
        ),
      ],
      verify: (bloc) {
        final state = bloc.state;
        expect(state.amenities.map((a) => a.code), ['wi-fi', 'new-thing']);
        expect(state.amenities.first.emoji, '📶');
        expect(state.amenities.last.emoji, isNotEmpty);
        expect(state.needsLoadFor('en'), isFalse);
        expect(state.needsLoadFor('mk'), isTrue);
      },
    );

    blocTest<AmenitiesBloc, AmenitiesState>(
      'a failed request ends in failed',
      build: () => AmenitiesBloc(
        dio: Dio(BaseOptions(baseUrl: 'https://test'))
          ..httpClientAdapter = _FakeAdapter({}),
      ),
      act: (bloc) => bloc.add(const AmenitiesRequested('mk')),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.status, AmenitiesStatus.failed);
        expect(bloc.state.needsLoadFor('mk'), isTrue);
      },
    );
  });

  group('CategoriesBloc', () {
    CategoriesBloc categoriesWith(Map<String, (int, Object)> responses) {
      final dio = Dio(BaseOptions(baseUrl: 'https://test'))
        ..httpClientAdapter = _FakeAdapter(responses);
      return CategoriesBloc(dio: dio);
    }

    const categoriesResponse = {
      'success': true,
      'data': [
        {
          'id': 'stay',
          'parentCategoryId': null,
          'code': 'rural-stay',
          'name': 'Сместување',
        },
        {
          'id': 'rooms',
          'parentCategoryId': 'stay',
          'code': 'rooms',
          'name': 'Соби',
        },
        {
          'id': 'new',
          'parentCategoryId': null,
          'code': 'something-new',
          'name': 'Ново',
        },
      ],
    };

    blocTest<CategoriesBloc, CategoriesState>(
      'loads the categories; Home shows only the top-level ones',
      build: () =>
          categoriesWith({'/api/categories': (200, categoriesResponse)}),
      act: (bloc) => bloc.add(const CategoriesRequested('mk')),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        isA<CategoriesState>().having(
          (s) => s.status,
          'status',
          CategoriesStatus.loading,
        ),
        isA<CategoriesState>().having(
          (s) => s.status,
          'status',
          CategoriesStatus.loaded,
        ),
      ],
      verify: (bloc) {
        final state = bloc.state;
        expect(state.languageCode, 'mk');
        expect(state.categories, hasLength(3));
        expect(state.topLevel.map((c) => c.name), ['Сместување', 'Ново']);
        expect(state.topLevel.first.emoji, '🏠');
        // Unknown codes still get an emoji.
        expect(state.topLevel.last.emoji, isNotEmpty);
        expect(state.needsLoadFor('mk'), isFalse);
        expect(state.needsLoadFor('en'), isTrue);
      },
    );

    blocTest<CategoriesBloc, CategoriesState>(
      'a failed request ends in failed and can be retried',
      build: () => categoriesWith({}),
      act: (bloc) => bloc.add(const CategoriesRequested('mk')),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        isA<CategoriesState>().having(
          (s) => s.status,
          'status',
          CategoriesStatus.loading,
        ),
        isA<CategoriesState>()
            .having((s) => s.status, 'status', CategoriesStatus.failed)
            .having((s) => s.error, 'error', isNotNull),
      ],
      verify: (bloc) {
        expect(bloc.state.needsLoadFor('mk'), isTrue);
      },
    );
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

  /// Every request made, in order.
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
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
