import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/attraction.dart';
import 'package:vn_travel_companion/features/explore/domain/repositories/attraction_repository.dart';

part 'attraction_event.dart';
part 'attraction_state.dart';

class AttractionBloc extends Bloc<AttractionEvent, AttractionState> {
  final AttractionRepository _attractionRepository;

  AttractionBloc({
    required AttractionRepository attractionRepository,
  })  : _attractionRepository = attractionRepository,
        super(AttractionInitial()) {
    on<AttractionEvent>((event, emit) => emit(AttractionLoading()));

    on<GetHotAttractions>(_onGetHotAttractions);
    on<GetRecentViewedAttractions>(_onGetRecentViewedAttractions);
    on<UpsertRecentViewedAttractions>(_onUpsertRecentViewedAttractions);
    on<GetRecommendedAttraction>(_onGetRecommendedAttraction);
    on<GetRelatedAttractions>(_onGetRelatedAttractions);
  }

  void _onGetHotAttractions(
      GetHotAttractions event, Emitter<AttractionState> emit) async {
    final res = await _attractionRepository.getHotAttractions(
        limit: event.limit, offset: event.offset);
    res.fold(
      (l) => emit(AttractionFailure(l.message)),
      (r) => emit(AttractionsLoadedSuccess(r)),
    );
  }

  void _onGetRecentViewedAttractions(
      GetRecentViewedAttractions event, Emitter<AttractionState> emit) async {
    final res = await _attractionRepository.getRecentViewedAttractions(
        limit: event.limit);
    res.fold(
      (l) => emit(AttractionFailure(l.message)),
      (r) => emit(AttractionsLoadedSuccess(r)),
    );
  }

  void _onUpsertRecentViewedAttractions(UpsertRecentViewedAttractions event,
      Emitter<AttractionState> emit) async {
    final res = await _attractionRepository.upsertRecentViewedAttractions(
        attractionId: event.attractionId, userId: event.userId);
    res.fold(
      (l) => emit(AttractionFailure(l.message)),
      (r) => () {},
    );
  }

  void _onGetRecommendedAttraction(
      GetRecommendedAttraction event, Emitter<AttractionState> emit) async {
    final res = await _attractionRepository.getRecommendedAttractions(
        limit: event.limit, userId: event.userId);
    res.fold(
      (l) => emit(AttractionFailure(l.message)),
      (r) => emit(AttractionsLoadedSuccess(r)),
    );
  }

  void _onGetRelatedAttractions(
      GetRelatedAttractions event, Emitter<AttractionState> emit) async {
    final res = await _attractionRepository.getRelatedAttractions(
        attractionId: event.attractionId, limit: event.limit);
    res.fold(
      (l) => emit(AttractionFailure(l.message)),
      (r) => emit(AttractionsLoadedSuccess(r)),
    );
  }
}
