import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/event.dart';
import 'package:vn_travel_companion/features/explore/domain/repositories/event_repository.dart';

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
  }

  void _onGetHotEvents(GetHotEvents event, Emitter<EventState> emit) async {
    final res = await _eventRepository.getHotEvents();
    res.fold(
      (l) => emit(EventFailure(message: l.message)),
      (r) => emit(EventLoadedSuccess(events: r)),
    );
  }
}
