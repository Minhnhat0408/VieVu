import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/domain/repositories/trip_repository.dart';

part 'trip_details_state.dart';

class TripDetailsCubit extends Cubit<TripDetailsState> {
  final TripRepository _tripRepository;
  TripDetailsCubit({
    required TripRepository tripRepository,
  })  : _tripRepository = tripRepository,
        super(TripDetailsInitial());

  void getTripDetails({
    required String tripId,
  }) async {
    emit(TripDetailsLoading());
    final res = await _tripRepository.getTripDetails(tripId: tripId);
    res.fold(
      (failure) => emit(TripDetailsLoadedFailure(failure.message)),
      (trip) => emit(TripDetailsLoadedSuccess(trip)),
    );
  }


}
