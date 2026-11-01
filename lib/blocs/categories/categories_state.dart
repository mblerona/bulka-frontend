part of 'categories_bloc.dart';

enum CategoriesStatus { initial, loading, loaded, failed }

final class CategoriesState {
  const CategoriesState({
    this.categories = const [],
    this.status = CategoriesStatus.initial,
    this.languageCode,
    this.error,
  });

  /// Every category, including sub-categories. See [topLevel].
  final List<HomeCategory> categories;
  final CategoriesStatus status;

  /// The language [categories]' names are in (or are being loaded in).
  final String? languageCode;

  /// Set when [status] is [CategoriesStatus.failed].
  final ApiException? error;

  /// The main categories, as shown on Tourist Home.
  List<HomeCategory> get topLevel =>
      categories.where((c) => c.isTopLevel).toList();

  /// True when nothing is loaded or loading for [languageCode] yet (first
  /// visit, a language switch, or a failed attempt).
  bool needsLoadFor(String languageCode) =>
      status == CategoriesStatus.initial ||
      status == CategoriesStatus.failed ||
      this.languageCode != languageCode;

  CategoriesState loading(String languageCode) => CategoriesState(
    categories: categories,
    status: CategoriesStatus.loading,
    languageCode: languageCode,
  );

  CategoriesState loaded(List<HomeCategory> categories, String languageCode) =>
      CategoriesState(
        categories: categories,
        status: CategoriesStatus.loaded,
        languageCode: languageCode,
      );

  CategoriesState failed(ApiException error) => CategoriesState(
    categories: categories,
    status: CategoriesStatus.failed,
    languageCode: languageCode,
    error: error,
  );
}
