

import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/core/network/connection_checker.dart';
import 'package:vn_travel_companion/features/auth/data/datasources/profile_remote_datasource.dart';
import 'package:vn_travel_companion/features/auth/domain/entities/user.dart';
import 'package:vn_travel_companion/features/auth/domain/repository/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource   remoteDataSource;
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
    required String name,
    required String phone,
    required String address,
    required String avatar,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final user = await remoteDataSource.updateProfile(
        name: name,
        phone: phone,
        address: address,
        avatar: avatar,
      );

      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
