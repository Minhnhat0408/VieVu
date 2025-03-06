import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/features/auth/data/models/user_model.dart';

abstract interface class ProfileRemoteDataSource {
  Future<UserModel> getProfile({
    required String id,
  });

  Future<UserModel> updateProfile({
    required String name,
    required String phone,
    required String address,
    required String avatar,
  });

  // Future<void> updatePassword({
  //   required String password,
  // });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient supabaseClient;

  ProfileRemoteDataSourceImpl(
    this.supabaseClient,
  );

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
  Future<UserModel> updateProfile({
    required String name,
    required String phone,
    required String address,
    required String avatar,
  }) async {
    try {
      final response = await supabaseClient
          .from('profiles')
          .upsert({
            'name': name,
            'phone': phone,
            'address': address,
            'avatar': avatar,
          })
          .select()
          .single();
      return UserModel.fromJson(response);
    } catch (e) {
      throw const ServerException();
    }
  }

  // @override
  // Future<void> updatePassword({
  //   required String password,
  // }) async {
  //   try {
  //     await supabaseClient.auth.updateUser(UserAttributes(
  //       password: password,
  //     ));
  //   } catch (e) {
  //     throw const ServerException();
  //   }
  // }
}
