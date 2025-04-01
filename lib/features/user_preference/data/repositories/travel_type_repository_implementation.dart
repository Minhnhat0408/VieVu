import 'package:fpdart/fpdart.dart';
import 'package:vievu/core/error/failures.dart';
import 'package:vievu/core/network/connection_checker.dart';
import 'package:vievu/features/user_preference/data/datasources/travel_type_remote_datasource.dart';
import 'package:vievu/features/user_preference/domain/entities/travel_type.dart';
import 'package:vievu/features/user_preference/domain/repositories/travel_type_repository.dart';

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
