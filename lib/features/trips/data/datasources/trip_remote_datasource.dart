import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/features/trips/data/models/trip_model.dart';

abstract interface class TripRemoteDatasource {
  Future insertTrip({
    required String name,
    required String userId,
  });
  Future getCurrentUserTrips(
      {required String userId, String? status, bool? isPublished});

  Future getTrips({
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
  Future insertTrip({
    required String name,
    required String userId,
  }) async {
    try {
      await supabaseClient.from('trips').insert({
        'name': name,
        'owner_id': userId,
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future getTrips({
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
  Future getCurrentUserTrips(
      {required String userId, String? status, bool? isPublished}) async {
    try {
      var query = supabaseClient.from('trips').select().eq('owner_id', userId);

      if (status != null) {
        query = query.eq('status', status);
      }

      if (isPublished != null) {
        query = query.eq('is_published', isPublished);
      }

      final response = await query.order('created_at', ascending: false);

      return response.map((e) => TripModel.fromJson(e)).toList();
    } catch (e) {
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
