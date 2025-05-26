import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:vievu/core/error/failures.dart';
import 'package:vievu/features/auth/domain/entities/user.dart';

abstract interface class ProfileRepository {
  Future<Either<Failure, User>> getProfile({
    required String id,
  });

  Future<Either<Failure, User>> updateProfile({
    String? firstName,
    String? lastName,
    String? gender,
    String? phone,
    String? city,
    String? bio,
    File? avatar,
  });
}


// hover jump to the text messgae
// version summarize fallback
