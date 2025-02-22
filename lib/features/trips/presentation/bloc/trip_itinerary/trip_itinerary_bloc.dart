import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_itinerary.dart';
import 'package:vn_travel_companion/features/trips/domain/repositories/trip_itinerary_repository.dart';

part 'trip_itinerary_event.dart';
part 'trip_itinerary_state.dart';

class TripItineraryBloc extends Bloc<TripItineraryEvent, TripItineraryState> {
  final TripItineraryRepository _tripItineraryRepository;
  TripItineraryBloc({
    required TripItineraryRepository tripItineraryRepository,
  })  : _tripItineraryRepository = tripItineraryRepository,
        super(TripItineraryInitial()) {
    // on<TripItineraryEvent>((event, emit) {
    //   // TODO: implement event handler
    // });
    on<InsertTripItinerary>(_onInsertTripItinerary);
    on<GetTripItineraries>(_onGetTripItineraries);
    on<UpdateTripItinerary>(_onUpdateTripItinerary);
  }

  void _onInsertTripItinerary(
      InsertTripItinerary event, Emitter<TripItineraryState> emit) async {
    emit(TripItineraryLoading());
    final res = await _tripItineraryRepository.insertTripItinerary(
      tripId: event.tripId,
      serviceId: event.serviceId,
      latitude: event.latitude,
      longitude: event.longitude,
      title: event.title,
      note: event.note,
      time: event.time,
    );
    res.fold(
      (l) => emit(TripItineraryFailure(message: l.message)),
      (r) => emit(TripItineraryAddedSuccess(tripItinerary: r)),
    );
  }

  void _onGetTripItineraries(
      GetTripItineraries event, Emitter<TripItineraryState> emit) async {
    emit(TripItineraryLoading());
    final res = await _tripItineraryRepository.getTripItineraries(
      tripId: event.tripId,
    );
    res.fold(
      (l) => emit(TripItineraryFailure(message: l.message)),
      (r) => emit(TripItineraryLoadedSuccess(tripItineraries: r)),
    );
  }

  void _onUpdateTripItinerary(
      UpdateTripItinerary event, Emitter<TripItineraryState> emit) async {
    emit(TripItineraryLoading());
    final res = await _tripItineraryRepository.updateTripItinerary(
      id: event.id,
      note: event.note,
      time: event.time,
    );
    res.fold(
      (l) => emit(TripItineraryFailure(message: l.message)),
      (r) => emit(TripItineraryUpdatedSuccess(tripItinerary: r)),
    );
  }
}
