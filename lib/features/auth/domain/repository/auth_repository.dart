import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:vievu/core/error/failures.dart';
import 'package:vievu/features/auth/domain/entities/user.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });

  Future<Either<Failure, User>> logInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> getCurrentUserData();

  Future<Either<Failure, Unit>> logOut();

  Future<Either<Failure, User>> logInWithGoogle();

  Stream<supabase.AuthState> listenToAuthChanges();

  Future<Either<Failure, Unit>> sendPasswordResetEmail({
    required String email,
  });

  Future<Either<Failure, Unit>> updatePassword({
    required String password,
  });
}
