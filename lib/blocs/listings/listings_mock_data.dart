// Mock seed data until this feature is connected to the backend.
import 'package:bulka_frontend/models/listing_category.dart';
import 'package:bulka_frontend/models/listing_amenity.dart';
import 'package:bulka_frontend/models/provider_listing.dart';

List<ProviderListing> mockListings() {
  final now = DateTime.now();
  return [
    ProviderListing(
      id: '1',
      title: 'Villa Zdravkovski',
      status: ListingStatus.active,
      location: 'Брајчино, Преспа',
      reservationCount: 5,
      rating: 4.8,
      updatedAt: now.subtract(const Duration(days: 10)),
      category: ListingCategory.accommodation,
      price: 2770,
      description:
          'Пространа традиционална куќа во срцето на Преспа, опкружена со '
          'полиња и поглед кон езерото. Совршена за мирен одмор во '
          'природа, со дрвена тераса, домашна кујна и топла атмосфера за '
          'целото семејство.',
      amenities: const {
        ListingAmenity.wifi,
        ListingAmenity.parking,
        ListingAmenity.kitchen,
        ListingAmenity.airConditioning,
        ListingAmenity.tv,
        ListingAmenity.fireplace,
        ListingAmenity.hotWater,
      },
      guestCapacity: 6,
      hostSinceYear: 2021,
    ),
    ProviderListing(
      id: '2',
      title: 'Гостинска соба со појадок',
      status: ListingStatus.active,
      location: 'Охрид',
      reservationCount: 3,
      rating: 4.6,
      updatedAt: now.subtract(const Duration(days: 15)),
      category: ListingCategory.accommodation,
      price: 1980,
      description:
          'Топла и уредна гостинска соба во стара охридска куќа, само '
          'неколку минути пешачење од езерото. Вклучен домашен појадок '
          'секое утро.',
      amenities: const {
        ListingAmenity.wifi,
        ListingAmenity.hotWater,
        ListingAmenity.petsAllowed,
      },
      guestCapacity: 2,
      hostSinceYear: 2019,
    ),
    ProviderListing(
      id: '3',
      title: 'Дегустација на домашно вино',
      status: ListingStatus.active,
      location: 'Тиквеш',
      reservationCount: 2,
      rating: 4.9,
      updatedAt: now.subtract(const Duration(days: 20)),
      category: ListingCategory.gastronomy,
      price: 900,
      description:
          'Дегустација на домашно вино во винарија среде лозјата на '
          'Тиквеш, проследена со домашни мезиња и приказна за традицијата '
          'на семејството.',
      amenities: const {ListingAmenity.parking, ListingAmenity.farmAccess},
      guestCapacity: 8,
      hostSinceYear: 2022,
    ),
    ProviderListing(
      id: '4',
      title: 'Тура на фарма',
      status: ListingStatus.active,
      location: 'Брајчино, Преспа',
      reservationCount: 4,
      rating: 4.7,
      updatedAt: now.subtract(const Duration(days: 8)),
      category: ListingCategory.farmParticipation,
      price: 700,
      description:
          'Поминете еден ден на вистинска фарма — хранење на животните, '
          'берба во градината и учество во секојдневните активности, со '
          'домашен ручек на крајот.',
      amenities: const {
        ListingAmenity.parking,
        ListingAmenity.farmAccess,
        ListingAmenity.petsAllowed,
      },
      guestCapacity: 10,
      hostSinceYear: 2020,
    ),
    ProviderListing(
      id: '5',
      title: 'Работилница за сирење',
      status: ListingStatus.active,
      location: 'Крушево',
      reservationCount: 1,
      rating: 5.0,
      updatedAt: now.subtract(const Duration(days: 5)),
      category: ListingCategory.farmEducation,
      price: 850,
      description:
          'Научете го традиционалниот начин на правење сирење од '
          'крушевските планини, чекор по чекор, и однесете си дома '
          'сопствен производ.',
      amenities: const {ListingAmenity.parking, ListingAmenity.kitchen},
      guestCapacity: 6,
      hostSinceYear: 2023,
    ),
    ProviderListing(
      id: '6',
      title: 'Etno House Galičnik',
      status: ListingStatus.pendingReview,
      location: 'Галичник, Мавровско Езеро',
      updatedAt: now.subtract(const Duration(days: 2)),
    ),
    ProviderListing(
      id: '7',
      title: 'Планинарска тура',
      status: ListingStatus.pendingReview,
      location: 'Маврово',
      updatedAt: now.subtract(const Duration(hours: 10)),
    ),
    ProviderListing(
      id: '8',
      title: 'Prespa',
      status: ListingStatus.rejected,
      location: 'Преспа',
      rejectionReason: 'потребни се дополнителни слики.',
      updatedAt: now.subtract(const Duration(days: 4)),
    ),
    ProviderListing(
      id: '9',
      title: 'Стара Куќа Крушево',
      status: ListingStatus.archived,
      location: 'Крушево',
      updatedAt: now.subtract(const Duration(days: 45)),
    ),
  ];
}
