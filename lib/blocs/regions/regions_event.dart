part of 'regions_bloc.dart';

sealed class RegionsEvent {
  const RegionsEvent();
}

/// Load (or reload) the regions in [languageCode].
final class RegionsRequested extends RegionsEvent {
  const RegionsRequested(this.languageCode);

  final String languageCode;
}
