part of 'event_bloc.dart';

@immutable
sealed class EventEvent {}

class GetHotEvents extends EventEvent {}
