import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/features/trips/data/models/trip_itinerary_model.dart';

abstract interface class TripItineraryRemoteDatasource {
  Future<TripItineraryModel> insertTripItinerary({
    required String tripId,
    required DateTime time,
    required double latitude,
    required double longitude,
    required String title,
    String? note,
    int? serviceId,
  });

  Future updateTripItinerary({
    required int id,
    required bool isStartingPoint,
  });

  Future deleteTripItinerary({
    required String tripId,
    required int ItineraryId,
  });

  Future<List<TripItineraryModel>> getTripItineraries({
    required String tripId,
  });
}

class TripItineraryRemoteDatasourceImpl
    implements TripItineraryRemoteDatasource {
  final SupabaseClient supabaseClient;

  TripItineraryRemoteDatasourceImpl(
    this.supabaseClient,
  );

  @override
  Future<TripItineraryModel> insertTripItinerary({
    required String tripId,
    required DateTime time,
    required double latitude,
    required double longitude,
    required String title,
    String? note,
    int? serviceId,
  }) async {
    try {
      final res = await supabaseClient
          .from('trip_itineraries')
          .insert({
            'trip_id': tripId,
            'time': time.toIso8601String(),
            'latitude': latitude,
            'longitude': longitude,
            'title': title,
            'note': note,
            'service_id': serviceId,
          })
          .select('*, saved_services(*)')
          .single();

      return TripItineraryModel.fromJson(res);
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  @override
  Future updateTripItinerary({
    required int id,
    required bool isStartingPoint,
  }) async {
    try {
      await supabaseClient.from('trip_itinerary').update({
        'is_starting_point': isStartingPoint,
      }).eq('id', id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future deleteTripItinerary({
    required String tripId,
    required int ItineraryId,
  }) async {
    try {
      await supabaseClient
          .from('trip_itinerary')
          .delete()
          .eq('id', ItineraryId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<TripItineraryModel>> getTripItineraries({
    required String tripId,
  }) async {
    try {
      final res = await supabaseClient
          .from('trip_itineraries')
          .select('*, saved_services(*)')
          .eq('trip_id', tripId)
          .order('time', ascending: true);

      return res.map((e) => TripItineraryModel.fromJson(e)).toList();
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }
}
