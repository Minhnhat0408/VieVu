import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/saved_services.dart';
import 'package:vn_travel_companion/features/trips/domain/repositories/saved_service_repository.dart';

part 'saved_service_event.dart';
part 'saved_service_state.dart';

class SavedServiceBloc extends Bloc<SavedServiceEvent, SavedServiceState> {
  final SavedServiceRepository _savedServiceRepository;
  SavedServiceBloc({
    required SavedServiceRepository savedServiceRepository,
  })  : _savedServiceRepository = savedServiceRepository,
        super(SavedServiceInitial()) {
    // on<SavedServiceEvent>((event, emit) {
    //   // TODO: implement event handler
    // });

    on<InsertSavedService>(_onInsertSavedService);
    on<DeleteSavedService>(_onDeleteSavedService);
  }

  void _onInsertSavedService(
      InsertSavedService event, Emitter<SavedServiceState> emit) async {
    emit(SavedServiceLoading());
    final res = await _savedServiceRepository.insertSavedService(
      tripId: event.tripId,
      externalLink: event.externalLink,
      linkId: event.linkId,
      cover: event.cover,
      name: event.name,
      locationName: event.locationName,
      tagInfoList: event.tagInfoList,
      rating: event.rating,
      ratingCount: event.ratingCount,
      hotelStar: event.hotelStar,
      typeId: event.typeId,
      latitude: event.latitude,
      longitude: event.longitude,
    );
    res.fold(
      (l) => emit(SavedServiceFailure(message: l.message)),
      (r) => emit(SavedServiceActionSucess()),
    );
  }

  void _onDeleteSavedService(
      DeleteSavedService event, Emitter<SavedServiceState> emit) async {
    emit(SavedServiceLoading());
    final res = await _savedServiceRepository.deleteSavedService(
      linkId: event.linkId,
      tripId: event.tripId,
    );
    res.fold(
      (l) => emit(SavedServiceFailure(message: l.message)),
      (r) => emit(SavedServiceActionSucess()),
    );
  }
}
