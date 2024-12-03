import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/features/user_preference/domain/entities/travel_type.dart';

abstract interface class TravelTypeRepository {
  Future<Either<Failure, List<TravelType>>> getParentTravelTypes();

  Future<Either<Failure, List<TravelType>>> getTravelTypesByParentIds({
    required List<String> parentIds,
  });
}
