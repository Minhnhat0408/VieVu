import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vievu/core/error/exceptions.dart';
import 'package:vievu/features/trips/data/models/trip_member_model.dart';

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

  Future<void> inviteTripMember({
    required String tripId,
    required String userId,
  });

  Future<List<TripMemberRatingModel>> getRatedUsers({required String userId});
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
          .select('*, profiles(*), trip_reviews(*)')
          .eq('trip_id', tripId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (response != null) {
        response['reviewed'] = response['trip_reviews'] != null ? true : false;
      }
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
  Future<List<TripMemberRatingModel>> getRatedUsers(
      {required String userId}) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const ServerException("Không tìm thấy người dùng");
      }
      final data = await supabaseClient
          .from('user_ratings')
          .select(
              'rating, trip_participants!inner(user_id, trip_id,trips(name, cover)), profiles(*)')
          .eq('trip_participants.user_id', userId);

      // log(ratings.toString());
      return data.map((e) {
        return TripMemberRatingModel.fromJson(e).copyWith(
          tripName: e['trip_participants']['trips']['name'],
          tripId: e['trip_participants']['trip_id'],
          tripCover: e['trip_participants']['trips']['cover'],
        );
      }).toList();
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
      if (role != 'owner') {
        final res = await supabaseClient
            .from('trips')
            .select("max_member, trip_participants(count)")
            .eq('id', tripId)
            .single();
        if (res['trip_participants'][0]['count'] >= res['max_member']) {
          throw const ServerException("Số lượng thành viên đã đủ");
        }
      }

      await supabaseClient.from('trip_participants').insert({
        'trip_id': tripId,
        'user_id': userId,
        'role': role,
      });
    } catch (e) {
      log(e.toString());
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

  @override
  Future<void> inviteTripMember({
    required String tripId,
    required String userId,
  }) async {
    try {
      final res = await supabaseClient
          .from('trip_participants')
          .select("id")
          .eq('trip_id', tripId)
          .eq('user_id', userId)
          .maybeSingle();
      if (res != null) {
        throw const ServerException("Người dùng đã tham gia chuyến đi");
      }

      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const ServerException("Không tìm thấy người dùng");
      }
      final data = await supabaseClient
          .from('notifications')
          .select('id, is_accepted')
          .eq('receiver_id', userId)
          .eq('trip_id', tripId)
          .eq('sender_id', user.id)
          .eq('type', 'trip_invite')
          .maybeSingle();

      if (data != null) {
        if (data['is_accepted'] == null) {
          throw const ServerException("Đã mời người dùng này rồi");
        } else if (data['is_accepted'] == false) {
          throw const ServerException("Người dùng đã từ chối mời");
        } else {
          await supabaseClient.from('notifications').update({
            'is_accepted': null,
            'created_at': DateTime.now().toIso8601String(),
          }).eq('id', data['id']);
        }
      } else {
        await supabaseClient.from('notifications').insert({
          'content': 'đã mời bạn tham gia chuyến đi',
          'sender_id': user.id,
          'receiver_id': userId,
          'trip_id': tripId,
          'type': 'trip_invite',
        });
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
