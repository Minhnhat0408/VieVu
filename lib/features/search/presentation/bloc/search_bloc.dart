import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/features/search/domain/entities/explore_search_result.dart';
import 'package:vievu/features/search/domain/entities/home_search_result.dart';
import 'package:vievu/features/search/domain/repositories/explore_search_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository _exploreSearchRepository;
  SearchBloc({
    required SearchRepository repository,
  })  : _exploreSearchRepository = repository,
        super(SearchInitial()) {
    on<SearchEvent>((event, emit) {
      return emit(SearchLoading());
    });
    on<SearchAll>(_onSearchAll);
    on<ExploreSearch>(_onExploreSearch);
    on<SearchHistory>(_onSearchHistory);
    on<EventsSearch>(_onEventsSearch);
    on<SearchExternalApi>(_onSearchExternalApi);
    on<SearchAllLocal>(_onSearchAllLocal);  
    on<SearchHome>(_onSearchHome);
  }

  void _onExploreSearch(ExploreSearch event, Emitter<SearchState> emit) async {
    final res = await _exploreSearchRepository.exploreSearch(
      searchText: event.searchText,
      limit: event.limit,
      tripId: event.tripId,
      offset: event.offset,
      searchType: event.searchType,
    );
    res.fold(
      (l) => emit(SearchError(message: l.message)),
      (r) => emit(SearchSuccess(results: r)),
    );
  }

  void _onSearchHome(SearchHome event, Emitter<SearchState> emit) async {
    final res = await _exploreSearchRepository.homeSearch(
      searchText: event.searchText,
      limit: event.limit,
      offset: event.offset,
      searchType: event.searchType,
    );
    res.fold(
      (l) => emit(SearchError(message: l.message)),
      (r) => emit(SearchHomeSuccess(results: r)),
    );
  }

  void _onEventsSearch(EventsSearch event, Emitter<SearchState> emit) async {
    final res = await _exploreSearchRepository.searchEvents(
      searchText: event.searchText,
      limit: event.limit,
      tripId: event.tripId,
      page: event.page,
    );
    res.fold(
      (l) => emit(SearchError(message: l.message)),
      (r) => emit(SearchSuccess(results: r)),
    );
  }

  void _onSearchExternalApi(
      SearchExternalApi event, Emitter<SearchState> emit) async {
    final res = await _exploreSearchRepository.searchExternalApi(
      searchText: event.searchText,
      limit: event.limit,
      tripId: event.tripId,
      page: event.page,
      searchType: event.searchType,
    );
    res.fold(
      (l) => emit(SearchError(message: l.message)),
      (r) => emit(SearchSuccess(results: r)),
    );
  }

  void _onSearchHistory(SearchHistory event, Emitter<SearchState> emit) async {
    await _exploreSearchRepository.upsertSearchHistory(
      searchText: event.searchText,
      cover: event.cover,
      userId: event.userId,
      title: event.title,
      address: event.address,
      linkId: event.linkId,
      externalLink: event.externalLink,
    );
  }

  void _onSearchAll(SearchAll event, Emitter<SearchState> emit) async {
    final res = await _exploreSearchRepository.searchAll(
      searchText: event.searchText,
      limit: event.limit,
      offset: event.offset,
      tripId: event.tripId,
    );
    res.fold(
      (l) => emit(SearchError(message: l.message)),
      (r) => emit(SearchSuccess(results: r)),
    );
  }

  void _onSearchAllLocal(SearchAllLocal event, Emitter<SearchState> emit) async {
    final res = await _exploreSearchRepository.searchAllLocal(
      searchText: event.searchText,
      limit: event.limit,
      offset: event.offset,
      tripId: event.tripId,
    );
    res.fold(
      (l) => emit(SearchError(message: l.message)),
      (r) => emit(SearchSuccess(results: r)),
    );
  }
}
