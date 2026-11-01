part of 'amenities_bloc.dart';

sealed class AmenitiesEvent {
  const AmenitiesEvent();
}

/// Load (or reload) the amenities. [languageCode] is the language the
/// request is made in, so the state knows which language its names are in.
final class AmenitiesRequested extends AmenitiesEvent {
  const AmenitiesRequested(this.languageCode);

  final String languageCode;
}
