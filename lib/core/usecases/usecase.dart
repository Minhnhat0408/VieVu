import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/failures.dart';

abstract interface class UseCase<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call(Params params);

}

class NoParams {}
abstract interface class StreamUseCase<SuccessType, Params> {
  Stream<SuccessType?> call(Params params);
}