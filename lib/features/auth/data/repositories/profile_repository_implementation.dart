import 'dart:developer';
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/core/network/connection_checker.dart';
import 'package:vn_travel_companion/features/auth/data/datasources/profile_remote_datasource.dart';
import 'package:vn_travel_companion/features/auth/domain/entities/user.dart';
import 'package:vn_travel_companion/features/auth/domain/repository/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;
  const ProfileRepositoryImpl(this.remoteDataSource, this.connectionChecker);

  @override
  Future<Either<Failure, User>> getProfile({
    required String id,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final user = await remoteDataSource.getProfile(
        id: id,
      );

      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    String? firstName,
    String? lastName,
    String? bio,
    String? phone,
    String? gender,
    String? city,
    File? avatar,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }

      String? imageUrl;
      if (avatar != null) {
        imageUrl = await remoteDataSource.uploadAvatar(
          file: avatar,
        );
      }
      log('imageUrl: $imageUrl');
      final user = await remoteDataSource.updateProfile(
        firstName: firstName,
        gender: gender,
        lastName: lastName,
        bio: bio,
        phone: phone,
        city: city,
        avatar: imageUrl,
      );

      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  supabase.RealtimeChannel listenToUserLocations({
    required String userId,
    required String tripId,
    required Function({
      required UserPosition userPosition,
      required String eventType,
    }) callback,
  }) {
    return remoteDataSource.listenToUserLocations(
      userId: userId,
      tripId: tripId,
      callback: callback,
    );
  }
}
