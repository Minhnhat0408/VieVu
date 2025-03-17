import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/features/user_preference/domain/entities/preference.dart';

abstract interface class PreferenceRepository {
  Future<Either<Failure, Preference?>> getUserPreference({
    required String userId,
  });

  Future<Either<Failure, Preference>> insertUserPreference({
    required String userId,
    required double budget,
    required double avgRating,
    required int ratingCount,
    required Map<String, dynamic> prefsDF,
  });

  Future<Either<Failure, Preference>> updateUserPreference({
    required String userId,
    double? budget,
    double? avgRating,
    int? ratingCount,
    Map<String, dynamic>? prefsDF,
  });

  Future<Either<Failure, Preference>> updateUserPreferenceDF({
     required int attractionId,

    required Preference currentPref,
    required String action,
  });
}
