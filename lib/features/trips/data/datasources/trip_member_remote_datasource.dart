import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/features/trips/data/models/trip_member_model.dart';

abstract interface class TripMemberRemoteDatasource {
  Future<List<TripMemberModel>> getTripMembers({
    required String tripId,
  });

  Future insertTripMember({
    required String tripId,
    required String userId,
    required String role,
  });

  Future updateTripMember({
    required String tripId,
    required String userId,
    String? role,
    bool? isBanned,
  });

  Future<TripMemberModel?> getMyTripMemberToTrip({
    required String tripId,
  });

  Future<void> deleteTripMember({
    required String tripId,
    required String userId,
  });

  Future<void> rateTripMember({
    required int memberId,
    required int rating,
  });
}

class TripMemberRemoteDatasourceImpl implements TripMemberRemoteDatasource {
  final SupabaseClient supabaseClient;

  TripMemberRemoteDatasourceImpl(
    this.supabaseClient,
  );

  @override
  Future<TripMemberModel?> getMyTripMemberToTrip({
    required String tripId,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const ServerException("Không tìm thấy người dùng");
      }
      final response = await supabaseClient
          .from('trip_participants')
          .select('*, profiles(*)')
          .eq('trip_id', tripId)
          .eq('user_id', user.id)
          .maybeSingle();

      return response != null ? TripMemberModel.fromJson(response) : null;
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<TripMemberModel>> getTripMembers({
    required String tripId,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const ServerException("Không tìm thấy người dùng");
      }
      final response = await supabaseClient
          .from('trip_participants')
          .select('*, profiles(*), user_ratings(rating)')
          .eq('trip_id', tripId)
          .eq('user_ratings.rater_id', user.id)
          .order('created_at', ascending: true);

      log(response.toString());
      return response
          .map((e) => TripMemberModel.fromJson(e).copyWith(
                rating: e['user_ratings'].isNotEmpty
                    ? e['user_ratings'][0]['rating']
                    : 0,
              ))
          .toList();
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  @override
  Future insertTripMember({
    required String tripId,
    required String userId,
    required String role,
  }) async {
    try {
      final res = await supabaseClient
          .from('trips')
          .select("max_member, trip_participants(count)")
          .eq('id', tripId)
          .single();
      if (res['trip_participants'][0]['count'] >= res['max_member']) {
        throw const ServerException("Số lượng thành viên đã đủ");
      }
      await supabaseClient.from('trip_participants').insert({
        'trip_id': tripId,
        'user_id': userId,
        'role': role,
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future updateTripMember({
    required String tripId,
    required String userId,
    String? role,
    bool? isBanned,
  }) async {
    try {
      final buildUpdateObject = {
        if (role != null) 'role': role,
        if (isBanned != null) 'is_banned': isBanned,
      };
      await supabaseClient
          .from('trip_participants')
          .update(buildUpdateObject)
          .eq('trip_id', tripId)
          .eq('user_id', userId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteTripMember({
    required String tripId,
    required String userId,
  }) async {
    try {
      await supabaseClient
          .from('trip_participants')
          .delete()
          .eq('trip_id', tripId)
          .eq('user_id', userId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> rateTripMember({
    required int memberId,
    required int rating,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const ServerException("Không tìm thấy người dùng");
      }
      await supabaseClient.from('user_ratings').upsert({
        'rater_id': user.id,
        'ratee_id': memberId,
        'rating': rating,
      }, onConflict: "rater_id, ratee_id");
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }
}
