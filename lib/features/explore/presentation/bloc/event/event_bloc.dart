import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/features/explore/domain/entities/event.dart';
import 'package:vievu/features/explore/domain/repositories/event_repository.dart';

part 'event_event.dart';
part 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final EventRepository _eventRepository;
  EventBloc({
    required EventRepository repository,
  })  : _eventRepository = repository,
        super(EventInitial()) {
    on<EventEvent>((event, emit) => emit(EventLoading()));
    on<GetHotEvents>(_onGetHotEvents);
    on<GetEventDetails>(_onGetEventDetails);
  }

  void _onGetHotEvents(GetHotEvents event, Emitter<EventState> emit) async {
    emit(EventLoading());
    final res = await _eventRepository.getHotEvents(userId: event.userId);
    res.fold(
      (l) => emit(EventFailure(message: l.message)),
      (r) => emit(EventLoadedSuccess(events: r)),
    );
  }

  void _onGetEventDetails(
      GetEventDetails event, Emitter<EventState> emit) async {
    final res = await _eventRepository.getEventDetails(eventId: event.eventId);
    res.fold(
      (l) => emit(EventFailure(message: l.message)),
      (r) => emit(EventDetailsLoadedSuccess(event: r)),
    );
  }
}
