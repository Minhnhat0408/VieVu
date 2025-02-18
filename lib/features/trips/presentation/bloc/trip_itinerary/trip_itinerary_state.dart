part of 'trip_itinerary_bloc.dart';

@immutable
sealed class TripItineraryState {}

final class TripItineraryInitial extends TripItineraryState {}

final class TripItineraryLoading extends TripItineraryState {}

final class TripItineraryAddedSuccess extends TripItineraryState {
  final TripItinerary tripItinerary;

  TripItineraryAddedSuccess({
    required this.tripItinerary,
  });
}

final class TripItineraryFailure extends TripItineraryState {
  final String message;

  TripItineraryFailure({
    required this.message,
  });
}

final class TripItineraryLoadedSuccess extends TripItineraryState {
  final List<TripItinerary> tripItineraries;

  TripItineraryLoadedSuccess({
    required this.tripItineraries,
  });
}
