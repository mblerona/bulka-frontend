part of 'regions_bloc.dart';

enum RegionsStatus { initial, loading, loaded, failed }

final class RegionsState {
  const RegionsState({
    this.regions = const [],
    this.status = RegionsStatus.initial,
    this.languageCode,
    this.error,
  });

  final List<Region> regions;
  final RegionsStatus status;

  /// The language [regions]' names are in (or are being loaded in).
  final String? languageCode;

  /// Set when [status] is [RegionsStatus.failed].
  final ApiException? error;

  Region? byId(String? id) {
    if (id == null) return null;
    for (final region in regions) {
      if (region.id == id) return region;
    }
    return null;
  }

  /// True when nothing is loaded or loading for [languageCode] yet.
  bool needsLoadFor(String languageCode) =>
      status == RegionsStatus.initial ||
      status == RegionsStatus.failed ||
      this.languageCode != languageCode;

  RegionsState loading(String languageCode) => RegionsState(
    regions: regions,
    status: RegionsStatus.loading,
    languageCode: languageCode,
  );

  RegionsState loaded(List<Region> regions) => RegionsState(
    regions: regions,
    status: RegionsStatus.loaded,
    languageCode: languageCode,
  );

  RegionsState failed(ApiException error) => RegionsState(
    regions: regions,
    status: RegionsStatus.failed,
    languageCode: languageCode,
    error: error,
  );
}
