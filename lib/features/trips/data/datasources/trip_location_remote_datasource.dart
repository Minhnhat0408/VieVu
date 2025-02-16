import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/features/trips/data/models/trip_location_model.dart';

abstract interface class TripLocationRemoteDatasource {
  Future<TripLocationModel> insertTripLocation({
    required String tripId,
    required int locationId,
  });

  Future updateTripLocation({
    required int id,
    required bool isStartingPoint,
  });

  Future deleteTripLocation({
    required String tripId,
    required int locationId,
  });

  Future<List<TripLocationModel>> getTripLocations({
    required String tripId,
  });
}

class TripLocationRemoteDatasourceImpl implements TripLocationRemoteDatasource {
  final SupabaseClient supabaseClient;

  TripLocationRemoteDatasourceImpl(
    this.supabaseClient,
  );

  @override
  Future<TripLocationModel> insertTripLocation({
    required String tripId,
    required int locationId,
  }) async {
    try {
      final res = await supabaseClient
          .from('trip_locations')
          .insert({
            'trip_id': tripId,
            'location_id': locationId,
            'is_starting_point': false,
          })
          .select('*,locations(*)')
          .single();

      await supabaseClient
          .from('trips')
          .update({
            'cover': res['locations']['cover'],
          })
          .eq('id', tripId)
          .isFilter('cover', null);

      return TripLocationModel.fromJson(res);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future updateTripLocation({
    required int id,
    required bool isStartingPoint,
  }) async {
    try {
      await supabaseClient.from('trip_locations').update({
        'is_starting_point': isStartingPoint,
      }).eq('id', id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future deleteTripLocation({
    required String tripId,
    required int locationId,
  }) async {
    try {
      await supabaseClient
          .from('trip_locations')
          .delete()
          .eq('trip_id', tripId)
          .eq('location_id', locationId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<TripLocationModel>> getTripLocations({
    required String tripId,
  }) async {
    try {
      final res = await supabaseClient
          .from('trip_locations')
          .select('*, locations(*)')
          .eq('trip_id', tripId);

      return res.map((e) => TripLocationModel.fromJson(e)).toList();
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }
}
