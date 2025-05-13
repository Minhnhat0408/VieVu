import 'dart:developer';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vievu/core/error/exceptions.dart';
import 'package:vievu/features/auth/data/models/user_model.dart';

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
      final response = await supabaseClient
          .from('profiles')
          .select('*, trip_participants(count)')
          .eq('id', id)
          .single();
      final data = await supabaseClient
          .from('user_ratings')
          .select('rating, trip_participants!inner(user_id)')
          .eq('trip_participants.user_id', id);

      List<int> ratings =
          data.map((ratingEntry) => ratingEntry["rating"] as int).toList();

      // Calculate count & average
      int ratingCount = ratings.length;
      double avgRating =
          ratingCount > 0 ? ratings.reduce((a, b) => a + b) / ratingCount : 0.0;
      return UserModel.fromJson(response).copyWith(
        tripCount: response['trip_participants'].first['count'] as int,
        ratingCount: ratingCount,
        avgRating: avgRating,
      );
    } catch (e) {
      log(e.toString());
      throw ServerException(
        e.toString(),
      );
    }
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
          .select('*, trip_participants(count)')
          .single();
      final data = await supabaseClient
          .from('user_ratings')
          .select('rating, trip_participants!inner(user_id)')
          .eq('trip_participants.user_id', user.id);

      List<int> ratings =
          data.map((ratingEntry) => ratingEntry["rating"] as int).toList();

      // Calculate count & average
      int ratingCount = ratings.length;
      double avgRating =
          ratingCount > 0 ? ratings.reduce((a, b) => a + b) / ratingCount : 0.0;
      return UserModel.fromJson(response).copyWith(
        tripCount: response['trip_participants'].first['count'] as int,
        ratingCount: ratingCount,
        avgRating: avgRating,
      );
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }
}
