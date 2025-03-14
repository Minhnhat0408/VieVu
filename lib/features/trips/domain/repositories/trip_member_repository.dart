import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_member.dart';

abstract interface class TripMemberRepository {
  Future<Either<Failure, List<TripMember>>> getTripMembers({
    required String tripId,
  });

  Future<Either<Failure, TripMember?>> getMyTripMemberToTrip({
    required String tripId,
  });
  Future<Either<Failure, Unit>> insertTripMember({
    required String tripId,
    required String userId,
    required String role,
  });

  Future<Either<Failure, Unit>> updateTripMember({
    required String tripId,
    required String userId,
    String? role,
    bool? isBanned,
  });

  Future<Either<Failure, Unit>> deleteTripMember({
    required String tripId,
    required String userId,
  });

  Future<Either<Failure, Unit>> rateTripMember({
    required int memberId,
    required int rating,
  });
}
