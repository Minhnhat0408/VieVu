import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_location.dart';
import 'package:vn_travel_companion/features/trips/domain/repositories/trip_location_repository.dart';

part 'trip_location_event.dart';
part 'trip_location_state.dart';

class TripLocationBloc extends Bloc<TripLocationEvent, TripLocationState> {
  final TripLocationRepository _tripLocationRepository;
  TripLocationBloc({
    required TripLocationRepository tripLocationRepository,
  })  : _tripLocationRepository = tripLocationRepository,
        super(TripLocationInitial()) {
    on<InsertTripLocation>(_onInsertTripLocation);
    on<DeleteTripLocation>(_onDeleteTripLocation);
    on<GetTripLocations>(_onGetTripLocations);
  }

  void _onInsertTripLocation(
      InsertTripLocation event, Emitter<TripLocationState> emit) async {
    emit(TripLocationLoading());
    final res = await _tripLocationRepository.insertTripLocation(
      tripId: event.tripId,
      locationId: event.locationId,
    );
    res.fold(
      (l) => emit(TripLocationFailure(message: l.message)),
      (r) =>
          emit(TripLocationAddedSuccess(tripId: event.tripId, tripLocation: r)),
    );
  }

  void _onDeleteTripLocation(
      DeleteTripLocation event, Emitter<TripLocationState> emit) async {
    emit(TripLocationLoading());
    final res = await _tripLocationRepository.deleteTripLocation(
      tripId: event.tripId,
      locationId: event.locationId,
    );
    res.fold(
      (l) => emit(TripLocationFailure(message: l.message)),
      (r) => emit(TripLocationDeletedSuccess(
          tripId: event.tripId,
          locationId: event.locationId,
          locationName: event.locationName)),
    );
  }

  void _onGetTripLocations(
      GetTripLocations event, Emitter<TripLocationState> emit) async {
    emit(TripLocationLoading());
    final res = await _tripLocationRepository.getTripLocations(
      tripId: event.tripId,
    );
    res.fold(
      (l) => emit(TripLocationFailure(message: l.message)),
      (r) => emit(TripLocationsLoaded(tripLocations: r)),
    );
  }
}
