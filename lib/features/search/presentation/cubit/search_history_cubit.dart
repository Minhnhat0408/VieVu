import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/search/domain/entities/explore_search_result.dart';
import 'package:vn_travel_companion/features/search/domain/repositories/explore_search_repository.dart';

part 'search_history_state.dart';

class SearchHistoryCubit extends Cubit<SearchHistoryState> {
  final ExploreSearchRepository _exploreSearchRepository;
  SearchHistoryCubit({
    required ExploreSearchRepository repository,
  })  : _exploreSearchRepository = repository,
        super(SearchHistoryInitial());

  void getSearchHistory(String userId) async {
    emit(SearchHistoryLoading());
    final res = await _exploreSearchRepository.getSearchHistory(
      userId: userId,
    );
    res.fold(
      (l) => emit(SearchHistoryError(message: l.message)),
      (r) => emit(SearchHistorySuccess(searchHistory: r)),
    );
  }
}
