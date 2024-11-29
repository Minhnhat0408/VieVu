import 'package:vn_travel_companion/core/usecases/usecase.dart';
import 'package:vn_travel_companion/features/auth/domain/entities/user.dart';
import 'package:vn_travel_companion/features/auth/domain/repository/auth_repository.dart';

class ListenToAuthChanges implements StreamUseCase<User?, NoParams> {
  final AuthRepository repository;

  ListenToAuthChanges(this.repository);
  @override
  Stream<User?> call(NoParams params) {
    return repository.listenToAuthChanges();
  }
}
