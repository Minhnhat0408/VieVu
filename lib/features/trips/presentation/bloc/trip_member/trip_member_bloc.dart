import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_member.dart';
import 'package:vn_travel_companion/features/trips/domain/repositories/trip_member_repository.dart';

part 'trip_member_event.dart';
part 'trip_member_state.dart';

class TripMemberBloc extends Bloc<TripMemberEvent, TripMemberState> {
  final TripMemberRepository _tripMemberRepository;
  TripMemberBloc({
    required TripMemberRepository tripMemberRepository,
  })  : _tripMemberRepository = tripMemberRepository,
        super(TripMemberInitial()) {
    on<TripMemberEvent>((event, emit) {});
    on<GetTripMembers>(_onGetTripMembers);
    on<InsertTripMember>(_onInsertTripMember);
    on<UpdateTripMember>(_onUpdateTripMember);
    on<DeleteTripMember>(_onDeleteTripMember);

  }

  void _onInsertTripMember(InsertTripMember event, Emitter<TripMemberState> emit) async {
    emit(TripMemberActionLoading());
    final res = await _tripMemberRepository.insertTripMember(
      tripId: event.tripId,
      userId: event.userId,
      role: event.role,
    );
    res.fold(
      (l) => emit(TripMemberFailure(message: l.message)),
      (r) => emit(TripMemberInsertedSuccess(tripMember: r)),
    );
  }

  void _onUpdateTripMember(UpdateTripMember event, Emitter<TripMemberState> emit) async {
    emit(TripMemberActionLoading());
    final res = await _tripMemberRepository.updateTripMember(
      tripId: event.tripId,
      userId: event.userId,
      role: event.role,
      isBanned: event.isBanned,
    );
    res.fold(
      (l) => emit(TripMemberFailure(message: l.message)),
      (r) => emit(TripMemberUpdatedSuccess(tripMember: r)),
    );
  }


  void _onDeleteTripMember(DeleteTripMember event, Emitter<TripMemberState> emit) async {
    emit(TripMemberActionLoading());
    final res = await _tripMemberRepository.deleteTripMember(
      tripId: event.tripId,
      userId: event.userId,
    );
    res.fold(
      (l) => emit(TripMemberFailure(message: l.message)),
      (r) => emit(TripMemberDeletedSuccess(tripMemberId: event.userId)),
    );
  }

  void _onGetTripMembers(GetTripMembers event, Emitter<TripMemberState> emit) async {
    emit(TripMemberLoading());
    final res = await _tripMemberRepository.getTripMembers(
      tripId: event.tripId,
    );
    res.fold(
      (l) => emit(TripMemberFailure(message: l.message)),
      (r) => emit(TripMemberLoadedSuccess(tripMembers: r)),
    );
  }


}
