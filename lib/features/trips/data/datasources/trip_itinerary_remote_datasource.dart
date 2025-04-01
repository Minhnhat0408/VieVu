import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vievu/core/error/exceptions.dart';
import 'package:vievu/features/trips/data/models/trip_itinerary_model.dart';

abstract interface class TripItineraryRemoteDatasource {
  Future<TripItineraryModel> insertTripItinerary({
    required String tripId,
    required DateTime time,
    double? latitude,
    double? longitude,
    required String title,
    String? note,
    int? serviceId,
  });

  Future<TripItineraryModel> updateTripItinerary({
    required int id,
    String? note,
    DateTime? time,
    bool? isDone,
  });

  Future deleteTripItinerary({
    required int id,
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
    double? latitude,
    double? longitude,
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
  Future<TripItineraryModel> updateTripItinerary({
    required int id,
    String? note,
    DateTime? time,
    bool? isDone,
  }) async {
    try {
      Map<String, dynamic> updateObject = {};

      if (note != null && note.isNotEmpty) {
        updateObject['note'] = note;
      }
      if (time != null) {
        updateObject['time'] = time.toIso8601String();
      }
      if (isDone != null) {
        updateObject['is_done'] = isDone;
      }

      log(time.toString());
      final res = await supabaseClient
          .from('trip_itineraries')
          .update(updateObject)
          .eq('id', id)
          .select('*, saved_services(*)')
          .single();

      return TripItineraryModel.fromJson(res);
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  @override
  Future deleteTripItinerary({
    required int id,
  }) async {
    try {
      await supabaseClient.from('trip_itineraries').delete().eq('id', id);
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
