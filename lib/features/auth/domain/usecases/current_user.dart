import 'package:fpdart/fpdart.dart';
import 'package:vievu/core/error/failures.dart';
import 'package:vievu/core/usecases/usecase.dart';
import 'package:vievu/features/auth/domain/entities/user.dart';
import 'package:vievu/features/auth/domain/repository/auth_repository.dart';

class CurrentUser implements UseCase<User, NoParams> {
  final AuthRepository repository;

  CurrentUser(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return repository.getCurrentUserData();
  }
}
