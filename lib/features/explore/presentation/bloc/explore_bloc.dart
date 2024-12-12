import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/attraction.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/location.dart';
import 'package:vn_travel_companion/features/explore/domain/repositories/explore_repository.dart';

part 'explore_event.dart';
part 'explore_state.dart';

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final ExploreRepository _exploreRepository;

  ExploreBloc({
    required ExploreRepository exploreRepository,
  })  : _exploreRepository = exploreRepository,
        super(ExploreInitial()) {
    on<ExploreEvent>((event, emit) => emit(ExploreLoading()));
    on<GetAttraction>(_onGetAttraction);
    on<GetHotAttractions>(_onGetHotAttractions);
    on<GetRecentViewedAttractions>(_onGetRecentViewedAttractions);
    on<UpsertRecentViewedAttractions>(_onUpsertRecentViewedAttractions);
  }

  void _onGetAttraction(GetAttraction event, Emitter<ExploreState> emit) async {
    final res = await _exploreRepository.getAttraction(
        attractionId: event.attractionId);
    res.fold(
      (l) => emit(ExploreFailure(l.message)),
      (r) => emit(AttractionDetailsLoadedSuccess(r)),
    );
  }

  void _onGetHotAttractions(
      GetHotAttractions event, Emitter<ExploreState> emit) async {
    final res = await _exploreRepository.getHotAttractions(
        limit: event.limit, offset: event.offset);
    res.fold(
      (l) => emit(ExploreFailure(l.message)),
      (r) => emit(AttractionsLoadedSuccess(r)),
    );
  }

  void _onGetRecentViewedAttractions(
      GetRecentViewedAttractions event, Emitter<ExploreState> emit) async {
    final res =
        await _exploreRepository.getRecentViewedAttractions(limit: event.limit);
    res.fold(
      (l) => emit(ExploreFailure(l.message)),
      (r) => emit(AttractionsLoadedSuccess(r)),
    );
  }

  void _onUpsertRecentViewedAttractions(
      UpsertRecentViewedAttractions event, Emitter<ExploreState> emit) async {
    final res = await _exploreRepository.upsertRecentViewedAttractions(
        attractionId: event.attractionId, userId: event.userId);
    res.fold(
      (l) => emit(ExploreFailure(l.message)),
      (r) => () {},
    );
  }
}
