part of 'categories_bloc.dart';

sealed class CategoriesEvent {
  const CategoriesEvent();
}

/// Load (or reload) the categories. [languageCode] is the language the
/// request is made in, so the state knows which language its names are in.
final class CategoriesRequested extends CategoriesEvent {
  const CategoriesRequested(this.languageCode);

  final String languageCode;
}
