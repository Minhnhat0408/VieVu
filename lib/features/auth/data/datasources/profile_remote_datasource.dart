import 'dart:developer';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/features/auth/data/models/user_model.dart';

abstract interface class ProfileRemoteDataSource {
  Future<UserModel> getProfile({
    required String id,
  });

  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? gender,
    String? bio,
    String? phone,
    String? city,
    String? avatar,
  });
  Future<String> uploadAvatar({
    required File file,
  });
  // Future<void> updatePassword({
  //   required String password,
  // });

  RealtimeChannel listenToUserLocations({
    required String userId,
    required String tripId,
    required Function({
      required UserPositionModel userPosition,
      required String eventType,
    }) callback,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient supabaseClient;

  ProfileRemoteDataSourceImpl(
    this.supabaseClient,
  );
  @override
  Future<String> uploadAvatar({
    required File file,
  }) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) {
      throw const ServerException("Không tìm thấy người dùng");
    }
    try {
      await supabaseClient.storage.from('profile_avatars').upload(
            "${user.id}.jpg",
            file,
          );

      return supabaseClient.storage.from('profile_avatars').getPublicUrl(
            "${user.id}.jpg",
          );
    } on StorageException catch (e) {
      log(e.toString());
      if (e.message == "The resource already exists") {
        await supabaseClient.storage.from('profile_avatars').update(
              "${user.id}.jpg",
              file,
            );

        log('updated');
        return supabaseClient.storage.from('profile_avatars').getPublicUrl(
              "${user.id}.jpg",
            );
      } else {
        throw ServerException(e.toString());
      }
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> getProfile({
    required String id,
  }) async {
    try {
      final response =
          await supabaseClient.from('profiles').select().eq('id', id).single();
      return UserModel.fromJson(response);
    } catch (e) {
      throw const ServerException();
    }
  }

  @override
  RealtimeChannel listenToUserLocations({
    required String userId,
    required String tripId,
    required Function({
      required UserPositionModel userPosition,
      required String eventType,
    }) callback,
  }) {
    return supabaseClient
        .channel('user_location:$tripId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'user_locations',
          filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'trip_id',
              value: tripId),
          callback: (payload) async {
            // callback();
            final newRecord = payload.newRecord;
          },
        )
        .subscribe();
  }

  @override
  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? city,
    String? gender,
    String? bio,
    String? avatar,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const ServerException("Không tìm thấy người dùng");
      }

      final buildUpdateObject = {
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (phone != null) 'phone': phone,
        if (city != null) 'city': city,
        if (avatar != null) 'avatar_url': avatar,
        if (gender != null) 'gender': gender,
        if (bio != null) 'bio': bio,
      };
      log(buildUpdateObject.toString());
      final response = await supabaseClient
          .from('profiles')
          .update(buildUpdateObject)
          .eq('id', user.id)
          .select()
          .single();
      return UserModel.fromJson(response);
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }
}
