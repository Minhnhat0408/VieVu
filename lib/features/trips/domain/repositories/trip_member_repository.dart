import 'package:fpdart/fpdart.dart';
import 'package:vievu/core/error/failures.dart';
import 'package:vievu/features/trips/domain/entities/trip_member.dart';

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

  Future<Either<Failure, TripMember>> updateTripMember({
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

  Future<Either<Failure, Unit>> inviteTripMember({
    required String tripId,
    required String userId,
  });

  Future<Either<Failure, List<TripMemberRating>>> getRatedUsers({
    required String userId,
  });

  Future<Either<Failure, List<TripMember>>> getBannedUsers({
    required String tripId,
  });
}
