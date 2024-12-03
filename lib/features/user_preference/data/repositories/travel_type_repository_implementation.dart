import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/core/network/connection_checker.dart';
import 'package:vn_travel_companion/features/user_preference/data/datasources/travel_type_remote_datasource.dart';
import 'package:vn_travel_companion/features/user_preference/domain/entities/travel_type.dart';
import 'package:vn_travel_companion/features/user_preference/domain/repositories/travel_type_repository.dart';



class TravelTypeRepositoryImpl implements TravelTypeRepository {
  final TravelTypeRemoteDatasource remoteDataSource;
  final ConnectionChecker connectionChecker;
  const TravelTypeRepositoryImpl(this.remoteDataSource, this.connectionChecker);

  @override
  Future<Either<Failure, List<TravelType>>> getParentTravelTypes() async {
    try {
      final travelTypes = await remoteDataSource.getParentTravelTypes();
      return right(travelTypes);
    } on Exception {
      return left(Failure("Error getting travel types"));
    }
  }

  @override
  Future<Either<Failure, List<TravelType>>> getTravelTypesByParentIds(
      {required List<String> parentIds}) async {
    try {
      final travelTypes = await remoteDataSource.getTravelTypesByParentIds(
          parentIds: parentIds);
      return right(travelTypes);
    } on Exception {
      return left(Failure("Error getting travel types"));
    }
  }
}
