part of 'nearby_attractions_cubit.dart';

@immutable
sealed class NearbyAttractionsState {}

final class NearbyAttractionsInitial extends NearbyAttractionsState {}

final class NearbyAttractionsLoading extends NearbyAttractionsState {}

final class NearbyAttractionsFailure extends NearbyAttractionsState {
  final String message;

  NearbyAttractionsFailure(this.message);
}

final class NearbyAttractionsLoadedSuccess extends NearbyAttractionsState {
  final List<Attraction> attractions;

  NearbyAttractionsLoadedSuccess(this.attractions);
}