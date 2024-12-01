import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/core/usecases/usecase.dart';
import 'package:vn_travel_companion/features/auth/domain/repository/auth_repository.dart';

class SendResetPasswordEmail implements UseCase<Unit, ResetEmailParams> {
  final AuthRepository authRepository;

  const SendResetPasswordEmail(this.authRepository);
  @override
  Future<Either<Failure, Unit>> call(ResetEmailParams params) async {
    return await authRepository.sendPasswordResetEmail(email: params.email);
  }
}

class ResetEmailParams {
  final String email; // nullable for Google login

  const ResetEmailParams({
    required this.email,
  });
}
