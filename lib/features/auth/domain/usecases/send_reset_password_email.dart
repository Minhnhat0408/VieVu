import 'package:fpdart/fpdart.dart';
import 'package:vievu/core/error/failures.dart';
import 'package:vievu/core/usecases/usecase.dart';
import 'package:vievu/features/auth/domain/repository/auth_repository.dart';

class SendResetPasswordEmail implements UseCase<Unit, ResetEmailParams> {
  final AuthRepository authRepository;

  const SendResetPasswordEmail(this.authRepository);
  @override
  Future<Either<Failure, Unit>> call(ResetEmailParams params) async {
    return await authRepository.sendPasswordResetEmail(email: params.email);
  }
}

class ResetEmailParams {
  final String email;

  const ResetEmailParams({
    required this.email,
  });
}
