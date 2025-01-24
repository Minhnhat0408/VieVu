import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/features/trips/data/models/trip_model.dart';

abstract interface class TripRemoteDatasource {
  Future<TripModel> insertTrip({
    required String name,
    required String userId,
  });
  Future<List<TripModel>> getCurrentUserTrips(
      {required String userId,
      String? status,
      bool? isPublished,
      required int limit,
      required int offset});

  Future<List<TripModel>> getCurrentUserTripsForSave({
    required String userId,
    String? status,
    bool? isPublished,
    required int id,
    required String type,
  });

  Future<List<TripModel>> getTrips({
    required int limit,
    required int offset,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? transports,
    List<String>? locationIds,
  });
  Future updateTrip({
    required String tripId,
    String? description,
    String? cover,
    DateTime? startDate,
    DateTime? endDate,
    int? maxMember,
    String? status,
    bool? isPublished,
    List<String>? transports,
  });

  Future deleteTrip({
    required String tripId,
  });
}

class TripRemoteDatasourceImpl implements TripRemoteDatasource {
  final SupabaseClient supabaseClient;

  TripRemoteDatasourceImpl(
    this.supabaseClient,
  );

  @override
  Future<TripModel> insertTrip({
    required String name,
    required String userId,
  }) async {
    try {
      final res = await supabaseClient.from('trips').insert({
        'name': name,
        'owner_id': userId,
        'status': 'planning',
      }).select();
      if (res.isEmpty) {
        throw const ServerException('Failed to insert trip');
      }
      log(res.first.toString());

      return TripModel.fromJson(res.first);
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<TripModel>> getTrips({
    required int limit,
    required int offset,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? transports,
    List<String>? locationIds,
  }) async {
    try {
      var query = supabaseClient.from('trips').select();

      if (status != null) {
        query = query.eq('status', status);
      }

      if (startDate != null) {
        query = query.gte('start_date', startDate);
      }

      if (endDate != null) {
        query = query.lte('end_date', endDate);
      }

      if (transports != null) {
        query = query.contains('transports', transports);
      }

      if (locationIds != null) {
        query = query.contains('location_ids', locationIds);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit);

      return response.map((e) => TripModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<TripModel>> getCurrentUserTripsForSave({
    required String userId,
    String? status,
    bool? isPublished,
    required int id,
    required String type,
  }) async {
    try {
      var query = supabaseClient
          .from('trips')
          .select(
              '*, trip_locations(locations(name, id), is_starting_point), saved_services(count)')
          .eq('owner_id', userId);

      if (status != null) {
        query = query.eq('status', status);
      }

      if (isPublished != null) {
        query = query.eq('is_published', isPublished);
      }

      final response = await query.order('created_at', ascending: false);

      return response.map((e) {
        final tripItem = e;
        tripItem['service_count'] = e['saved_services'][0]['count'];
        final locations = e['trip_locations'] as List;

        tripItem['locations'] = <String>[];
        if (type == "location" && locations.isNotEmpty) {
          // check if the trip contains the location id
          final locationIndex = locations.indexWhere((element) {
            return element['locations']['id'] == id;
          });

          if (locationIndex != -1) {
            tripItem['is_saved'] = true;
          }
          tripItem['locations'] = locations
              .map<String>(
                (e) => e['locations']['name'],
              )
              .toList();
        }

        return TripModel.fromJson(tripItem);
      }).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<TripModel>> getCurrentUserTrips(
      {required String userId,
      String? status,
      bool? isPublished,
      required int limit,
      required int offset}) async {
    try {
      log('hellooo');
      var query = supabaseClient
          .from('trips')
          .select(
              '*, trip_locations(locations(name), is_starting_point), saved_services(count)')
          .eq('owner_id', userId);

      if (status != null) {
        query = query.eq('status', status);
      }

      if (isPublished != null) {
        query = query.eq('is_published', isPublished);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit);

      return response.map((e) {
        final tripItem = e;
        tripItem['service_count'] = e['saved_services'][0]['count'];
        final locations = e['trip_locations'] as List;

        tripItem['locations'] = <String>[];
        if (locations.isNotEmpty) {
          final startingPointIndex = locations.indexWhere((element) {
            return element['is_starting_point'] == true;
          });
          if (startingPointIndex != -1) {
            final startingPoint = locations[startingPointIndex];
            locations.removeAt(startingPointIndex);
            locations.insert(0, startingPoint);
          }

          tripItem['locations'] = locations
              .map<String>(
                (e) => e['locations']['name'],
              )
              .toList();
        }

        return TripModel.fromJson(tripItem);
      }).toList();
    } catch (e) {
      log(e.toString());

      throw ServerException(e.toString());
    }
  }

  @override
  Future updateTrip({
    required String tripId,
    String? description,
    String? cover,
    DateTime? startDate,
    DateTime? endDate,
    int? maxMember,
    String? status,
    bool? isPublished,
    List<String>? transports,
  }) async {
    try {
      await supabaseClient.from('trips').update({
        'description': description,
        'cover': cover,
        'start_date': startDate,
        'end_date': endDate,
        'max_member': maxMember,
        'status': status,
        'is_published': isPublished,
        'transports': transports,
      }).eq('id', tripId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future deleteTrip({
    required String tripId,
  }) async {
    try {
      await supabaseClient.from('trips').delete().eq('id', tripId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
