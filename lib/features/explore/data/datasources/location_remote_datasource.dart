import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/features/explore/data/models/attraction_model.dart';
import 'package:vn_travel_companion/features/explore/data/models/location_model.dart';

abstract interface class LocationRemoteDatasource {
  Future<LocationModel?> getLocation({
    required int locationId,
  });

  Future<List<LocationModel>> getHotLocations({
    required int limit,
    required int offset,
  });

  // Future<List<LocationModel>> getAttractionsByCategory({
  //   required String category,
  //   required int limit,
  //   required int offset,
  // });

  Future<List<LocationModel>> getRecentViewedLocations({
    required int limit,
  });

  Future upsertRecentViewedLocations({
    required int locationId,
    required String userId,
  });
}

class LocationRemoteDatasourceImpl implements LocationRemoteDatasource {
  final SupabaseClient supabaseClient;

  LocationRemoteDatasourceImpl(
    this.supabaseClient,
  );

  @override
  Future<LocationModel?> getLocation({
    required int locationId,
  }) async {
    try {
      final response = await supabaseClient
          .from('locations')
          .select('*')
          .eq('id', locationId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return LocationModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<LocationModel>> getHotLocations({
    required int limit,
    required int offset,
  }) async {
    try {
      final response = await supabaseClient
          .from('locations')
          .select('*')
          .order('created_at', ascending: true)
          .range(offset, offset + limit);

      return response.map((e) => LocationModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<LocationModel>> getRecentViewedLocations({
    required int limit,
  }) async {
    try {
      final response = await supabaseClient
          .from('viewed_history')
          .select('*, locations(*)')
          .order('created_at', ascending: false)
          .range(0, limit);

      return response
          .map((e) => LocationModel.fromJson(e['locations']))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future upsertRecentViewedLocations({
    required int locationId,
    required String userId,
  }) async {
    try {
      await supabaseClient.from('viewed_history').upsert({
        'user_id': userId,
        'location_id': locationId,
        'viewed_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
