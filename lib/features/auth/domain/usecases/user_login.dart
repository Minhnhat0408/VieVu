import 'package:fpdart/fpdart.dart';
import 'package:vievu/core/error/failures.dart';
import 'package:vievu/core/usecases/usecase.dart';
import 'package:vievu/features/auth/domain/entities/user.dart';
import 'package:vievu/features/auth/domain/repository/auth_repository.dart';

enum LoginMethod { emailPassword, google }

class UserLogin implements UseCase<User, UserLoginParams> {
  final AuthRepository authRepository;

  const UserLogin(this.authRepository);

  @override
  Future<Either<Failure, User>> call(UserLoginParams params) async {
    if (params.loginMethod == LoginMethod.emailPassword) {
      // Login with email and password
      return await authRepository.logInWithEmailAndPassword(
          email: params.email!, password: params.password!);
    } else if (params.loginMethod == LoginMethod.google) {
      // Login with Google
      return await authRepository.logInWithGoogle();
    } else {
      return Left(Failure('Invalid login method'));
    }
  }
}

class UserLoginParams {
  final String? email; // nullable for Google login
  final String? password; // nullable for Google login
  final LoginMethod loginMethod;

  const UserLoginParams.emailPassword({
    required this.email,
    required this.password,
  }) : loginMethod = LoginMethod.emailPassword;

  const UserLoginParams.google()
      : email = null,
        password = null,
        loginMethod = LoginMethod.google;
}
