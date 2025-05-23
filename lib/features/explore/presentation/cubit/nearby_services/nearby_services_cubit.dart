import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/features/explore/domain/entities/hotel.dart';
import 'package:vievu/features/explore/domain/entities/restaurant.dart';
import 'package:vievu/features/explore/domain/entities/service.dart';
import 'package:vievu/features/explore/domain/repositories/attraction_repository.dart';

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
    required String userId,
  }) async {
    emit(NearbyServicesLoading());
    final servicesOrFailure =
        await _attractionRepository.getServicesNearAttraction(
      attractionId: attractionId,
      userId: userId,
      limit: limit,
      offset: offset,
      serviceType: serviceType,
      filterType: filterType,
    );

    servicesOrFailure.fold(
        (failure) => emit(NearbyServicesFailure(failure.message)), (services) {
      emit(NearbyServicesLoadedSuccess(services));
    });
  }

  Future<void> getNearbyServices({
    int limit = 10,
    int offset = 1,
    required double latitude,
    required double longitude,
    required String userId,
    required String filterType,
  }) async {
    emit(NearbyServicesLoading());
    final servicesOrFailure = await _attractionRepository.getAllServicesNearby(
      limit: limit,
      offset: offset,
      userId: userId,
      latitude: latitude,
      longitude: longitude,
      filterType: filterType,
    );

    servicesOrFailure.fold(
        (failure) => emit(NearbyServicesFailure(failure.message)), (services) {
      emit(AllNearbyServicesLoadedSuccess(services));
    });
  }

  Future<void> getRestaurantsWithFilter({
    int? categoryId1,
    List<int> serviceIds = const [],
    List<int> openTime = const [],
    required int limit,
    required String userId,
    required int offset,
    int? minPrice,
    int? maxPrice,
    double? lat,
    double? lon,
    int? locationId,
  }) async {
    emit(NearbyServicesLoading());
    final servicesOrFailure =
        await _attractionRepository.getRestaurantsWithFilter(
      categoryId1: categoryId1,
      serviceIds: serviceIds,
      openTime: openTime,
      limit: limit,
      offset: offset,
      userId: userId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      lat: lat,
      lon: lon,
      locationId: locationId,
    );

    servicesOrFailure.fold(
        (failure) => emit(NearbyServicesFailure(failure.message)), (services) {
      emit(RestaurantLoadedSuccess(services));
    });
  }

  Future<void> getHotelsWithFilter({
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int roomQuantity,
    required String userId,
    required int adultCount,
    required int childCount,
    int? star,
    required int limit,
    required int offset,
    int? minPrice,
    int? maxPrice,
    required String locationName,
  }) async {
    emit(NearbyServicesLoading());
    final servicesOrFailure = await _attractionRepository.getHotelsWithFilter(
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      roomQuantity: roomQuantity,
      adultCount: adultCount,
      childCount: childCount,
      star: star,
      limit: limit,
      userId: userId,
      offset: offset,
      minPrice: minPrice,
      maxPrice: maxPrice,
      locationName: locationName,
    );

    servicesOrFailure.fold(
        (failure) => emit(NearbyServicesFailure(failure.message)), (services) {
      emit(HotelLoadedSuccess(services));
    });
  }
}
