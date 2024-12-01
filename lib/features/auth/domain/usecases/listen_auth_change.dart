import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/usecases/usecase.dart';
import 'package:vn_travel_companion/features/auth/domain/repository/auth_repository.dart';

class ListenToAuthChanges implements StreamUseCase<AuthState, NoParams> {
  final AuthRepository repository;

  ListenToAuthChanges(this.repository);
  @override
  Stream<AuthState> call(NoParams params) {
    return repository.listenToAuthChanges();
  }
}
