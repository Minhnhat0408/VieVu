import 'dart:developer';

import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/core/network/connection_checker.dart';
import 'package:vn_travel_companion/features/user_preference/data/datasources/preferences_remote_datasource.dart';
import 'package:vn_travel_companion/features/user_preference/data/models/preference_model.dart';
import 'package:vn_travel_companion/features/user_preference/domain/entities/preference.dart';
import 'package:vn_travel_companion/features/user_preference/domain/repositories/preference_repository.dart';

class PreferenceRepositoryImpl implements PreferenceRepository {
  final PreferencesRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;
  const PreferenceRepositoryImpl(this.remoteDataSource, this.connectionChecker);

  @override
  Future<Either<Failure, Preference?>> getUserPreference({
    required String userId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final preference = await remoteDataSource.getUserPreference(
        userId: userId,
      );

      return right(preference);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Preference>> insertUserPreference({
    required String userId,
    required double budget,
    required double avgRating,
    required int ratingCount,
    required Map<String, dynamic> prefsDF,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final res = await remoteDataSource.insertUserPreference(
        userId: userId,
        budget: budget,
        avgRating: avgRating,
        ratingCount: ratingCount,
        prefsDF: prefsDF,
      );

      return right(res);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Preference>> updateUserPreference({
    required String userId,
    double? budget,
    double? avgRating,
    int? ratingCount,
    Map<String, dynamic>? prefsDF,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final preference = await remoteDataSource.updateUserPreference(
        userId: userId,
        budget: budget,
        avgRating: avgRating,
        ratingCount: ratingCount,
        prefsDF: prefsDF,
      );

      return right(preference);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Preference>> updateUserPreferenceDF({
      required int attractionId,

    required Preference currentPref,
    required String action,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final preference = await remoteDataSource.updateUserPreferenceDF(
        attractionId: attractionId,
        currentPref: PreferenceModel(
          budget: currentPref.budget,
          avgRating: currentPref.avgRating,
          ratingCount: currentPref.ratingCount,
          prefsDF: currentPref.prefsDF,
        ),
        action: action,
      );

      return right(preference);
    } on ServerException catch (e) {
      log(e.message);
      return left(Failure(e.message));
    }
  }
}
