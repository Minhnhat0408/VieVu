import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/features/trips/domain/entities/trip_member.dart';
import 'package:vievu/features/trips/domain/repositories/trip_member_repository.dart';
import 'package:vievu/features/trips/presentation/cubit/current_trip_member_info_cubit.dart';

part 'trip_member_event.dart';
part 'trip_member_state.dart';

class TripMemberBloc extends Bloc<TripMemberEvent, TripMemberState> {
  final TripMemberRepository _tripMemberRepository;
  final CurrentTripMemberInfoCubit _currentTripMemberInfoCubit;
  TripMemberBloc({
    required TripMemberRepository tripMemberRepository,
    required CurrentTripMemberInfoCubit currentTripMemberInfoCubit,
  })  : _tripMemberRepository = tripMemberRepository,
        _currentTripMemberInfoCubit = currentTripMemberInfoCubit,
        super(TripMemberInitial()) {
    on<TripMemberEvent>((event, emit) {});
    on<GetTripMembers>(_onGetTripMembers);
    on<InsertTripMember>(_onInsertTripMember);
    on<UpdateTripMember>(_onUpdateTripMember);
    on<DeleteTripMember>(_onDeleteTripMember);
    on<RateTripMember>(_onRateTripMember);
    on<InviteTripMember>(_onInviteTripMember);
    on<GetRatedUsers>(_onGetRatedUsers);
    on<GetBannedUsers>(_onGetBannedUsers);
  }

  void _onInsertTripMember(
      InsertTripMember event, Emitter<TripMemberState> emit) async {
    emit(TripMemberActionLoading());
    final res = await _tripMemberRepository.insertTripMember(
      tripId: event.tripId,
      userId: event.userId,
      role: event.role,
    );
    res.fold(
      (l) => emit(TripMemberFailure(message: l.message)),
      (r) {
        _currentTripMemberInfoCubit.loadTripMemberToTrip(tripId: event.tripId);
      },
    );
  }

  void _onUpdateTripMember(
      UpdateTripMember event, Emitter<TripMemberState> emit) async {
    emit(TripMemberActionLoading());
    final res = await _tripMemberRepository.updateTripMember(
      tripId: event.tripId,
      userId: event.userId,
      role: event.role,
      isBanned: event.isBanned,
    );
    res.fold(
      (l) => emit(TripMemberFailure(message: l.message)),
      (r) {
        emit(TripMemberUpdatedSuccess(tripMember: r));
        _currentTripMemberInfoCubit.loadTripMemberToTrip(tripId: event.tripId);
      },
    );
  }

  void _onDeleteTripMember(
      DeleteTripMember event, Emitter<TripMemberState> emit) async {
    emit(TripMemberActionLoading());
    final res = await _tripMemberRepository.deleteTripMember(
      tripId: event.tripId,
      userId: event.userId,
    );
    res.fold((l) => emit(TripMemberFailure(message: l.message)), (r) {
      _currentTripMemberInfoCubit.loadTripMemberToTrip(tripId: event.tripId);
      emit(TripMemberDeletedSuccess(
        tripMemberId: event.userId,
      ));
    });
  }

  void _onGetTripMembers(
      GetTripMembers event, Emitter<TripMemberState> emit) async {
    emit(TripMemberLoading());
    final res = await _tripMemberRepository.getTripMembers(
      tripId: event.tripId,
    );
    res.fold(
      (l) => emit(TripMemberFailure(message: l.message)),
      (r) => emit(TripMemberLoadedSuccess(tripMembers: r)),
    );
  }

  void _onRateTripMember(
      RateTripMember event, Emitter<TripMemberState> emit) async {
    emit(TripMemberActionLoading());
    final res = await _tripMemberRepository.rateTripMember(
      memberId: event.memberId,
      rating: event.rating,
    );
    res.fold(
      (l) => emit(TripMemberFailure(message: l.message)),
      (r) => emit(TripMemberRatedSuccess()),
    );
  }

  void _onInviteTripMember(
      InviteTripMember event, Emitter<TripMemberState> emit) async {
    emit(TripMemberActionLoading());
    final res = await _tripMemberRepository.inviteTripMember(
      tripId: event.tripId,
      userId: event.userId,
    );
    res.fold(
      (l) => emit(TripMemberFailure(message: l.message)),
      (r) => emit(TripMemberInvitedSuccess()),
    );
  }

  void _onGetRatedUsers(
      GetRatedUsers event, Emitter<TripMemberState> emit) async {
    emit(TripMemberLoading());
    final res = await _tripMemberRepository.getRatedUsers(
      userId: event.userId,
    );
    res.fold(
      (l) => emit(TripMemberFailure(message: l.message)),
      (r) => emit(UsersRatedLoadedSuccess(users: r)),
    );
  }

  void _onGetBannedUsers(
      GetBannedUsers event, Emitter<TripMemberState> emit) async {
    emit(TripMemberLoading());
    final res = await _tripMemberRepository.getBannedUsers(
      tripId: event.tripId,
    );
    res.fold(
      (l) => emit(TripMemberFailure(message: l.message)),
      (r) => emit(BannedUserLoadedSuccess(users: r)),
    );
  }
}
