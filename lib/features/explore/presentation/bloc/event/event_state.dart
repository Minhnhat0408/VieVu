part of 'event_bloc.dart';

@immutable
sealed class EventState {}

final class EventInitial extends EventState {}

final class EventLoading extends EventState {}

final class EventFailure extends EventState {
  final String message;

  EventFailure({required this.message});
}
final class EventLoadedSuccess extends EventState {
  final List<Event> events;

  EventLoadedSuccess({required this.events});
}

final class EventDetailsLoadedSuccess extends EventState {
  final Event event;

  EventDetailsLoadedSuccess({required this.event});
}
