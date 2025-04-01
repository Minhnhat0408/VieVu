import 'package:fpdart/fpdart.dart';
import 'package:vievu/core/error/failures.dart';
import 'package:vievu/core/usecases/usecase.dart';
import 'package:vievu/features/auth/domain/repository/auth_repository.dart';

class UserLogout implements UseCase<Unit, NoParams> {
  final AuthRepository authRepository;

  const UserLogout(this.authRepository);
  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    return await authRepository.logOut();
  }
}
