import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/models/listing_search_filter.dart';

part 'search_event.dart';
part 'search_state.dart';

/// The Tourist's current search filter (Search Results, filter sheet). The
/// search itself runs on the backend (`PublicListingsBloc`).
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchState(ListingSearchFilter())) {
    on<SearchFilterApplied>((event, emit) => emit(SearchState(event.filter)));
  }
}
