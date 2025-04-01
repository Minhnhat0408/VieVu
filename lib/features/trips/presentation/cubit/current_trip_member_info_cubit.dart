import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/features/trips/domain/entities/trip_member.dart';
import 'package:vievu/features/trips/domain/repositories/trip_member_repository.dart';

part 'current_trip_member_info_state.dart';

class CurrentTripMemberInfoCubit extends Cubit<CurrentTripMemberInfoState> {
  final TripMemberRepository _tripMemberRepository;
  CurrentTripMemberInfoCubit({
    required TripMemberRepository tripMemberRepository,
  })  : _tripMemberRepository = tripMemberRepository,
        super(CurrentTripMemberInfoInitial());

  void loadTripMemberToTrip({
    required String tripId,
  }) async {
    emit(CurrentTripMemberInfoLoading());
    final result =
        await _tripMemberRepository.getMyTripMemberToTrip(tripId: tripId);
    result.fold(
      (failure) => emit(CurrentTripMemberInfoError(message: failure.message)),
      (tripMember) => emit(
        CurrentTripMemberInfoLoaded(tripMember: tripMember),
      ),
    );
  }
}
