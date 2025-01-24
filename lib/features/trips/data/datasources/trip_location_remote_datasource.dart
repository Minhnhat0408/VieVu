import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';

abstract interface class TripLocationRemoteDatasource {
  Future insertTripLocation({
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
}

class TripLocationRemoteDatasourceImpl implements TripLocationRemoteDatasource {
  final SupabaseClient supabaseClient;

  TripLocationRemoteDatasourceImpl(
    this.supabaseClient,
  );

  @override
  Future insertTripLocation({
    required String tripId,
    required int locationId,
  }) async {
    try {
      final res = await supabaseClient.from('trip_locations').insert({
        'trip_id': tripId,
        'location_id': locationId,
        'is_starting_point': false,
      }).select('locations(cover)');

      await supabaseClient
          .from('trips')
          .update({
            'cover': res.first['locations']['cover'],
          })
          .eq('id', tripId)
          .isFilter('cover', null);
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
}
