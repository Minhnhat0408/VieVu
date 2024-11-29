import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/core/usecases/usecase.dart';
import 'package:vn_travel_companion/features/auth/domain/repository/auth_repository.dart';

class UserLogout implements UseCase<Unit, NoParams> {
  final AuthRepository authRepository;

  const UserLogout(this.authRepository);
  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    return await authRepository.logOut();
  }
}
