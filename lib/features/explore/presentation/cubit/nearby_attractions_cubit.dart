import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/attraction.dart';
import 'package:vn_travel_companion/features/explore/domain/repositories/attraction_repository.dart';

part 'nearby_attractions_state.dart';

class NearbyAttractionsCubit extends Cubit<NearbyAttractionsState> {
  final AttractionRepository _attractionRepository;

  NearbyAttractionsCubit({required AttractionRepository attractionRepository})
      : _attractionRepository = attractionRepository,
        super(NearbyAttractionsInitial());

  Future<void> fetchNearbyAttractions({
    required double latitude,
    required double longitude,
    int limit = 10,
    int offset = 0,
    int radius = 10,
  }) async {
    emit(NearbyAttractionsLoading());

    final result = await _attractionRepository.getNearbyAttractions(
      latitude: latitude,
      longitude: longitude,
      limit: limit,
      offset: offset,
      radius: radius,
    );

    result.fold(
      (failure) => emit(NearbyAttractionsFailure(failure.message)),
      (attractions) => emit(NearbyAttractionsLoadedSuccess(attractions)),
    );
  }
}
