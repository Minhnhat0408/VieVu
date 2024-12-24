import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/search/domain/entities/explore_search_result.dart';
import 'package:vn_travel_companion/features/search/domain/repositories/explore_search_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ExploreSearchRepository _exploreSearchRepository;
  SearchBloc({
    required ExploreSearchRepository repository,
  })  : _exploreSearchRepository = repository,
        super(SearchInitial()) {
    on<SearchEvent>((event, emit) {
      return emit(SearchLoading());
    });

    on<SearchAll>(_onSearchAll);
    on<ExploreSearch>(_onExploreSearch);
    on<EventsSearch>(_onEventsSearch);
    on<SearchExternalApi>(_onSearchExternalApi);

  }

  void _onSearchAll(SearchAll event, Emitter<SearchState> emit) async {
    final res = await _exploreSearchRepository.searchAll(
      searchText: event.searchText,
      limit: event.limit,
      offset: event.offset,
    );
    res.fold(
      (l) => emit(SearchError(message: l.message)),
      (r) => emit(SearchOverAllSuccess(results: r)),
    );
  }

  void _onExploreSearch(ExploreSearch event, Emitter<SearchState> emit) async {
    final res = await _exploreSearchRepository.exploreSearch(
      searchText: event.searchText,
      limit: event.limit,
      offset: event.offset,
      searchType: event.searchType,
    );
    res.fold(
      (l) => emit(SearchError(message: l.message)),
      (r) => emit(SearchSuccess(results: r)),
    );
  }

  void _onEventsSearch(EventsSearch event, Emitter<SearchState> emit) async {
    final res = await _exploreSearchRepository.searchEvents(
      searchText: event.searchText,
      limit: event.limit,
      page: event.page,
    );
    res.fold(
      (l) => emit(SearchError(message: l.message)),
      (r) => emit(SearchSuccess(results: r)),
    );
  }

  void _onSearchExternalApi(SearchExternalApi event, Emitter<SearchState> emit) async {
    final res = await _exploreSearchRepository.searchExternalApi(
      searchText: event.searchText,
      limit: event.limit,
      page: event.page,
      searchType: event.searchType,
    );
    res.fold(
      (l) => emit(SearchError(message: l.message)),
      (r) => emit(SearchSuccess(results: r)),
    );
  }
}
