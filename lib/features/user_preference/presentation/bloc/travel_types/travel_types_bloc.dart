import 'package:flutter/material.dart';
import 'package:vievu/features/user_preference/domain/entities/travel_type.dart';
import 'package:vievu/features/user_preference/domain/repositories/travel_type_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'travel_types_event.dart';
part 'travel_types_state.dart';

class TravelTypesBloc extends Bloc<TravelTypesEvent, TravelTypesState> {
  final TravelTypeRepository _travelTypeRepository;
  TravelTypesBloc({
    required TravelTypeRepository travelTypeRepository,
  })  : _travelTypeRepository = travelTypeRepository,
        super(TravelTypesInitial()) {
    on<TravelTypesEvent>((event, emit) => emit(TravelTypesLoading()));
    on<GetParentTravelTypes>(_onGetParentTravelTypes);
    on<GetTravelTypesByParentIds>(_onGetTravelTypesByParentIds);
  }

  void _onGetParentTravelTypes(
      GetParentTravelTypes event, Emitter<TravelTypesState> emit) async {
    final res = await _travelTypeRepository.getParentTravelTypes();
    res.fold(
      (l) => emit(TravelTypesFailure(l.message)),
      (r) => emit(TravelTypesLoadedSuccess(r)),
    );
  }

  void _onGetTravelTypesByParentIds(
      GetTravelTypesByParentIds event, Emitter<TravelTypesState> emit) async {
    final res = await _travelTypeRepository.getTravelTypesByParentIds(
        parentIds: event.parentIds);
    res.fold(
      (l) => emit(TravelTypesFailure(l.message)),
      (r) => emit(TravelTypesLoadedSuccess(r)),
    );
  }
}
