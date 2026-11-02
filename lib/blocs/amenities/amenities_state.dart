part of 'amenities_bloc.dart';

enum AmenitiesStatus { initial, loading, loaded, failed }

final class AmenitiesState {
  const AmenitiesState({
    this.amenities = const [],
    this.status = AmenitiesStatus.initial,
    this.languageCode,
    this.error,
  });

  final List<Amenity> amenities;
  final AmenitiesStatus status;

  /// The language [amenities]' names are in (or are being loaded in).
  final String? languageCode;

  /// Set when [status] is [AmenitiesStatus.failed].
  final ApiException? error;

  /// True when nothing is loaded or loading for [languageCode] yet (first
  /// visit, a language switch, or a failed attempt).
  bool needsLoadFor(String languageCode) =>
      status == AmenitiesStatus.initial ||
      status == AmenitiesStatus.failed ||
      this.languageCode != languageCode;

  AmenitiesState loading(String languageCode) => AmenitiesState(
    amenities: amenities,
    status: AmenitiesStatus.loading,
    languageCode: languageCode,
  );

  AmenitiesState loaded(List<Amenity> amenities, String languageCode) =>
      AmenitiesState(
        amenities: amenities,
        status: AmenitiesStatus.loaded,
        languageCode: languageCode,
      );

  AmenitiesState failed(ApiException error) => AmenitiesState(
    amenities: amenities,
    status: AmenitiesStatus.failed,
    languageCode: languageCode,
    error: error,
  );
}
