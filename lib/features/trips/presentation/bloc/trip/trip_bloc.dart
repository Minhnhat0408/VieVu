import 'dart:io';

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
    on<UpdateTrip>(_onUpdateTrip);
    on<DeleteTrip>(_onDeleteTrip);
    on<GetTrips>(_onGetTrips);
  }
  void _onUpdateTrip(UpdateTrip event, Emitter<TripState> emit) async {
    emit(TripActionLoading());
    final res = await _tripRepository.updateTrip(
      tripId: event.tripId,
      description: event.description,
      cover: event.cover,
      startDate: event.startDate,
      endDate: event.endDate,
      name: event.name,
      maxMember: event.maxMember,
      status: event.status,
      isPublished: event.isPublished,
      transports: event.transports,
    );

    res.fold(
      (l) => emit(TripActionFailure(l.message)),
      (r) => emit(TripActionSuccess(r)),
    );
  }

  void _onGetTrips(GetTrips event, Emitter<TripState> emit) async {
    emit(TripLoading());
    final res = await _tripRepository.getTrips(
      limit: event.limit,
      offset: event.offset,
      startDate: event.startDate,
      endDate: event.endDate,
      locationIds: event.locationIds,
      status: event.status,
      transports: event.transports,
    );

    res.fold(
      (l) => emit(TripLoadedFailure(l.message)),
      (r) => emit(TripPostsLoadedSuccess(r)),
    );
  }

  void _onDeleteTrip(DeleteTrip event, Emitter<TripState> emit) async {
    emit(TripActionLoading());
    final res = await _tripRepository.deleteTrip(tripId: event.id);
    res.fold(
      (l) => emit(TripActionFailure(l.message)),
      (r) => emit(TripDeletedSuccess()),
    );
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
        userId: event.userId, id: event.id, status: "planning");

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
