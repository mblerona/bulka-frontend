import 'package:bulka_frontend/core/network/api_environment.dart';
import 'package:bulka_frontend/models/amenity.dart';
import 'package:bulka_frontend/models/home_category.dart';
import 'package:bulka_frontend/models/listing_category.dart';
import 'package:bulka_frontend/models/provider_listing.dart';

/// A published listing as Tourists see it, from the backend.
///
/// `GET /api/listings` (search, Home) fills the summary fields;
/// `GET /api/listings/{slug}` plus `GET /api/itemized-listings/{slug}`
/// (Listing Details) also fill [description], [providerName],
/// [imageUrls] and [items] — see [hasDetails].
///
/// Names (title, categories, amenities) are already translated by the
/// backend from the `Accept-Language` header.
class PublicListing {
  const PublicListing({
    required this.id,
    required this.slug,
    required this.title,
    this.shortDescription = '',
    this.settlementName,
    this.municipalityName,
    this.regionName,
    this.coverImageUrl,
    this.priceAmount,
    this.averageRating,
    this.reviewCount = 0,
    this.categories = const [],
    this.amenities = const [],
    this.hasDetails = false,
    this.description = '',
    this.providerName,
    this.imageUrls = const [],
    this.items = const [],
  });

  /// One item of `GET /api/listings` → `data.items`.
  factory PublicListing.fromSearchJson(Map<String, dynamic> json) {
    return PublicListing(
      id: json['id'] as String,
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      shortDescription: json['shortDescription'] as String? ?? '',
      settlementName: json['settlementName'] as String?,
      municipalityName: json['municipalityName'] as String?,
      regionName: json['regionName'] as String?,
      coverImageUrl: resolveMediaUrl(json['coverImageUrl'] as String?),
      priceAmount: (json['priceAmount'] as num?)?.toDouble(),
      averageRating: _averageRating(json),
      reviewCount: _reviewCount(json),
      categories: _taxonomy(json['categories'], HomeCategory.fromJson),
      amenities: _taxonomy(json['amenities'], Amenity.fromJson),
    );
  }

  /// `GET /api/listings/{slug}` → `data`, plus the items from
  /// `GET /api/itemized-listings/{slug}` (empty if it has none).
  factory PublicListing.fromDetailJson(
    Map<String, dynamic> json, {
    List<ListingItem> items = const [],
  }) {
    final images = [
      for (final image in json['images'] as List<dynamic>? ?? const [])
        if (image is Map<String, dynamic>) image,
    ];
    // Cover first, then the provider's own order.
    images.sort((a, b) {
      final cover =
          (b['isCover'] == true ? 1 : 0) - (a['isCover'] == true ? 1 : 0);
      if (cover != 0) return cover;
      return ((a['sortOrder'] as num?) ?? 0).compareTo(
        (b['sortOrder'] as num?) ?? 0,
      );
    });
    final imageUrls = [
      for (final image in images)
        ?resolveMediaUrl(image['publicUrl'] as String?),
    ];
    final provider = json['provider'];
    final description = json['description'] as String?;
    return PublicListing(
      id: json['id'] as String,
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      shortDescription: json['shortDescription'] as String? ?? '',
      settlementName: json['settlementName'] as String?,
      municipalityName: json['municipalityName'] as String?,
      regionName: json['regionName'] as String?,
      coverImageUrl: imageUrls.isEmpty ? null : imageUrls.first,
      priceAmount: (json['priceAmount'] as num?)?.toDouble(),
      averageRating: _averageRating(json),
      reviewCount: _reviewCount(json),
      categories: _taxonomy(json['categories'], HomeCategory.fromJson),
      amenities: _taxonomy(json['amenities'], Amenity.fromJson),
      hasDetails: true,
      description: description == null || description.trim().isEmpty
          ? json['shortDescription'] as String? ?? ''
          : description,
      providerName: provider is Map<String, dynamic>
          ? provider['businessName'] as String?
          : null,
      imageUrls: imageUrls,
      items: items,
    );
  }

  final String id;

  /// What Listing Details is opened by (`/api/listings/{slug}`).
  final String slug;
  final String title;
  final String shortDescription;
  final String? settlementName;
  final String? municipalityName;
  final String? regionName;
  final String? coverImageUrl;

  /// The listing's own price. Null for itemized listings (all of them so
  /// far): each item has its own price instead — see [lowestItemPrice].
  final double? priceAmount;
  final double? averageRating;
  final int reviewCount;
  final List<HomeCategory> categories;
  final List<Amenity> amenities;

  /// False for listings that only come from a search result.
  final bool hasDetails;
  final String description;
  final String? providerName;
  final List<String> imageUrls;
  final List<ListingItem> items;

  /// Village and municipality, e.g. "Габрово, Струмица".
  String get location {
    final parts = <String>[];
    for (final part in [settlementName, municipalityName]) {
      if (part != null && part.trim().isNotEmpty && !parts.contains(part)) {
        parts.add(part);
      }
    }
    return parts.join(', ');
  }

  /// The cheapest item, for "from …" prices. Null when nothing has a
  /// price.
  ListingItem? get lowestPricedItem {
    ListingItem? lowest;
    for (final item in items) {
      final price = item.price;
      if (price == null) continue;
      if (lowest == null || price < lowest.price!) lowest = item;
    }
    return lowest;
  }

  double? get lowestItemPrice => lowestPricedItem?.price;

  /// The first accommodation item: the existing booking form books nights,
  /// so only those can be booked for now.
  ListingItem? get bookableItem {
    for (final item in items) {
      if (item.kind == ListingItemKind.accommodation && item.price != null) {
        return item;
      }
    }
    return null;
  }

  /// This listing in the shape the booking form, reservations and
  /// availability still use (they're on sample data until booking moves
  /// to the backend). Null when there's nothing nightly to book.
  ProviderListing? toBookingListing() {
    final item = bookableItem;
    if (item == null) return null;
    return ProviderListing(
      id: id,
      title: title,
      status: ListingStatus.active,
      location: location,
      updatedAt: DateTime(2026),
      category: ListingCategory.accommodation,
      description: description,
      price: item.price!,
      guestCapacity: item.capacity ?? 1,
    );
  }

  static double? _averageRating(Map<String, dynamic> json) {
    final summary = json['ratingSummary'];
    if (summary is! Map<String, dynamic>) return null;
    return (summary['averageRating'] as num?)?.toDouble();
  }

  static int _reviewCount(Map<String, dynamic> json) {
    final summary = json['ratingSummary'];
    if (summary is! Map<String, dynamic>) return 0;
    return (summary['reviewCount'] as num?)?.toInt() ?? 0;
  }

  static List<T> _taxonomy<T>(
    Object? raw,
    T Function(Map<String, dynamic>) parse,
  ) {
    if (raw is! List) return const [];
    return [
      for (final item in raw)
        if (item is Map<String, dynamic>) parse(item),
    ];
  }
}

enum ListingItemKind { accommodation, experience, other }

/// One bookable item of an itemized listing (a room, a tour, a meal), from
/// `GET /api/itemized-listings/{slug}` → `data.items`.
class ListingItem {
  const ListingItem({
    required this.id,
    required this.kind,
    required this.title,
    this.description = '',
    this.price,
    this.perPerson = false,
    this.capacity,
  });

  factory ListingItem.fromJson(Map<String, dynamic> json) {
    final kind = switch (json['kind']) {
      'Accommodation' => ListingItemKind.accommodation,
      'Experience' => ListingItemKind.experience,
      _ => ListingItemKind.other,
    };
    final accommodation = json['accommodation'];
    final experience = json['experience'];
    double? price;
    var perPerson = false;
    int? capacity;
    if (accommodation is Map<String, dynamic>) {
      price = (accommodation['nightlyPriceAmount'] as num?)?.toDouble();
      perPerson = accommodation['priceBasis'] == 'PerPerson';
      capacity = (accommodation['guestCapacity'] as num?)?.toInt();
    } else if (experience is Map<String, dynamic>) {
      price = (experience['priceAmount'] as num?)?.toDouble();
      perPerson = experience['pricingModel'] == 'PerPerson';
      capacity = (experience['capacity'] as num?)?.toInt();
    }
    return ListingItem(
      id: json['id'] as String,
      kind: kind,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: price,
      perPerson: perPerson,
      capacity: capacity,
    );
  }

  final String id;
  final ListingItemKind kind;
  final String title;
  final String description;

  /// Per night for accommodation; per booking (or per person, see
  /// [perPerson]) for experiences.
  final double? price;
  final bool perPerson;

  /// Most guests it takes.
  final int? capacity;
}

/// The backend returns uploaded images as paths ("/media/…") and demo ones
/// as full URLs.
String? resolveMediaUrl(String? url) {
  if (url == null || url.trim().isEmpty) return null;
  if (url.startsWith('/')) return '${ApiEnvironment.baseUrl}$url';
  return url;
}
