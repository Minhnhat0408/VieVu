import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/service.dart';
import 'package:vn_travel_companion/features/explore/domain/repositories/attraction_repository.dart';

part 'nearby_services_state.dart';

class NearbyServicesCubit extends Cubit<NearbyServicesState> {
  final AttractionRepository _attractionRepository;
  NearbyServicesCubit({
    required AttractionRepository attractionRepository,
  })  : _attractionRepository = attractionRepository,
        super(NearbyServicesInitial());

  Future<void> getServicesNearAttraction({
    required int attractionId,
    int limit = 20,
    int offset = 1,
    required int serviceType,
    required String filterType,
  }) async {
    emit(NearbyServicesLoading());
    final servicesOrFailure =
        await _attractionRepository.getServicesNearAttraction(
      attractionId: attractionId,
      limit: limit,
      offset: offset,
      serviceType: serviceType,
      filterType: filterType,
    );

    servicesOrFailure.fold(
        (failure) => emit(NearbyServicesFailure(failure.message)), (services) {
      log("$services services");
      emit(NearbyServicesLoadedSuccess(services));
    });
  }
}
