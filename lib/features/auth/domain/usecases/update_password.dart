import 'package:fpdart/fpdart.dart';
import 'package:vievu/core/error/failures.dart';
import 'package:vievu/core/usecases/usecase.dart';
import 'package:vievu/features/auth/domain/repository/auth_repository.dart';

class UpdatePassword implements UseCase<Unit, UpdatePasswordParams> {
  final AuthRepository authRepository;

  const UpdatePassword(this.authRepository);
  @override
  Future<Either<Failure, Unit>> call(UpdatePasswordParams params) async {
    return await authRepository.updatePassword(password: params.password);
  }
}

class UpdatePasswordParams {
  final String password; // nullable for Google login

  const UpdatePasswordParams({
    required this.password,
  });
}
