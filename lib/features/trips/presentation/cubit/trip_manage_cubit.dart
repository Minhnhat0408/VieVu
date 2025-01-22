import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/trips/domain/repositories/trip_repository.dart';

part 'trip_manage_state.dart';

class TripManageCubit extends Cubit<TripManageState> {
  final TripRepository _tripRepository;
  TripManageCubit({
    required TripRepository tripRepository,
  })  : _tripRepository = tripRepository,
        super(TripManageInitial());

  void addTrip({
    required String name,
    required String userId,
  }) {
    emit(TripManageLoading());

    _tripRepository
        .insertTrip(
      name: name,
      userId: userId,
    )
        .then((value) {
      emit(TripManageActionSuccess());
    }).catchError((error) {
      emit(TripManageLoadedFailure(error.toString()));
    });
  }
}
