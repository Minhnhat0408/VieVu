part of 'explore_bloc.dart';

@immutable
sealed class ExploreState {}

final class ExploreInitial extends ExploreState {}

final class ExploreLoading extends ExploreState {}

final class ExploreFailure extends ExploreState {
  final String message;

  ExploreFailure(this.message);
}

final class AttractionDetailsLoadedSuccess extends ExploreState {
  final Attraction attraction;

  AttractionDetailsLoadedSuccess(this.attraction);
}

final class AttractionsLoadedSuccess extends ExploreState {
  final List<Attraction> attractions;

  AttractionsLoadedSuccess(this.attractions);
}

final class LocationsLoadedSuccess extends ExploreState {
  final Location locations;

  LocationsLoadedSuccess(this.locations);
}
