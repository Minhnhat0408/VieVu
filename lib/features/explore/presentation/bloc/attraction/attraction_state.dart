part of 'attraction_bloc.dart';

@immutable
sealed class AttractionState {}

final class AttractionInitial extends AttractionState {}

final class AttractionLoading extends AttractionState {}

final class AttractionFailure extends AttractionState {
  final String message;

  AttractionFailure(this.message);
}

final class AttractionDetailsLoadedSuccess extends AttractionState {
  final Attraction attraction;

  AttractionDetailsLoadedSuccess(this.attraction);
}

final class AttractionsLoadedSuccess extends AttractionState {
  final List<Attraction> attractions;

  AttractionsLoadedSuccess(this.attractions);
}

