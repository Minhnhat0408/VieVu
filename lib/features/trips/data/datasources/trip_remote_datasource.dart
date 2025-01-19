import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/features/trips/data/models/saved_service_model.dart';

abstract interface class TripRemoteDatasource {
  Future insertTrip({
    required String name,
    required String userId,
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
