import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/location.dart';
import 'package:vn_travel_companion/features/explore/domain/repositories/location_repository.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository _locationRepository;
  LocationBloc({
    required LocationRepository repository,
  })  : _locationRepository = repository,
        super(LocationInitial()) {
    on<LocationEvent>((event, emit) {
      // TODO: implement event handler
      return emit(LocationLoading());
    });

    on<GetLocation>(_onGetLocation);
    on<GetHotLocations>(_onGetHotLocations);
    on<GetRecentViewedLocations>(_onGetRecentViewedLocations);
    on<UpsertRecentViewedLocations>(_onUpsertRecentViewedLocations);
  }

  void _onGetLocation(GetLocation event, Emitter<LocationState> emit) async {
    final res = await _locationRepository.getLocation(locationId: event.locationId);
    res.fold(
      (l) => emit(LocationError(message: l.message)),
      (r) => emit(LocationDetailsLoadedSuccess(location: r)),
    );
  }

  void _onGetHotLocations(
      GetHotLocations event, Emitter<LocationState> emit) async {
    final res = await _locationRepository.getHotLocations(
        limit: event.limit, offset: event.offset);
    res.fold(
      (l) => emit(LocationError(message: l.message)),
      (r) => emit(LocationsLoadedSuccess(locations: r)),
    );
  }

  void _onGetRecentViewedLocations(
      GetRecentViewedLocations event, Emitter<LocationState> emit) async {
    final res = await _locationRepository.getRecentViewedLocations(limit: event.limit);
    res.fold(
      (l) => emit(LocationError(message: l.message)),
      (r) => emit(LocationsLoadedSuccess(locations: r)),
    );
  }

  void _onUpsertRecentViewedLocations(
      UpsertRecentViewedLocations event, Emitter<LocationState> emit) async {
    final res = await _locationRepository.upsertRecentViewedLocations(
        locationId: event.locationId, userId: event.userId);
    res.fold(
      (l) => emit(LocationError(message: l.message)),
      (r) => () {},
    );
  }
}
