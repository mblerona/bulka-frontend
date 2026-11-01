import 'package:flutter_bloc/flutter_bloc.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

/// The Tourist's favourite listings (the heart on Listing Details).
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc() : super(FavoritesState(const {})) {
    on<FavoriteToggled>((event, emit) {
      final ids = Set.of(state.listingIds);
      if (!ids.remove(event.listingId)) ids.add(event.listingId);
      emit(FavoritesState(ids));
    });
  }
}
