import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/domain/repositories/trip_repository.dart';

part 'trip_event.dart';
part 'trip_state.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  final TripRepository _tripRepository;

  TripBloc({
    required TripRepository tripRepository,
  })  : _tripRepository = tripRepository,
        super(TripInitial()) {
    on<AddTrip>(_onAddTrip);
    on<GetCurrentUserTrips>(_onGetCurrentUserTrips);
    on<GetSavedToTrips>(_onGetSavedToTrips);
  }

  void _onAddTrip(AddTrip event, Emitter<TripState> emit) async {
    emit(TripActionLoading());
    final res = await _tripRepository.insertTrip(
      name: event.name,
      userId: event.userId,
    );
    res.fold(
      (l) => emit(TripLoadedFailure(l.message)),
      (r) => emit(TripActionSuccess(r)),
    );
  }

  void _onGetSavedToTrips(
      GetSavedToTrips event, Emitter<TripState> emit) async {
    emit(TripLoading());
    final res = await _tripRepository.getCurrentUserTripsForSave(
        userId: event.userId,
        id: event.id,
        type: event.type,
        status: "planning");

    res.fold(
      (l) => emit(TripLoadedFailure(l.message)),
      (r) => emit(SavedToTripLoadedSuccess(r)),
    );
  }

  void _onGetCurrentUserTrips(
      GetCurrentUserTrips event, Emitter<TripState> emit) async {
    emit(TripLoading());
    final res = await _tripRepository.getCurrentUserTrips(
        userId: event.userId,
        status: event.status,
        isPublished: event.isPublished,
        limit: event.limit,
        offset: event.offset);

    res.fold(
      (l) => emit(TripLoadedFailure(l.message)),
      (r) => emit(TripLoadedSuccess(r)),
    );
  }
}
