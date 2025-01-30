part of 'event_bloc.dart';

@immutable
sealed class EventEvent {}

class GetHotEvents extends EventEvent {
  final String userId;

  GetHotEvents({required this.userId});
}
