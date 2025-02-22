import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/chat/data/models/chat_model.dart';
import 'package:vn_travel_companion/features/chat/domain/entities/chat.dart';
import 'package:vn_travel_companion/features/chat/domain/repositories/chat_repository.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  ChatBloc({
    required ChatRepository chatRepository,
  })  : _chatRepository = chatRepository,
        super(ChatInitial()) {
    on<InsertChat>(_onInsertChat);
    on<InsertChatMembers>(_onInsertChatMembers);

    on<GetChatHeads>(_onGetChatHeads);
  }

  void _onInsertChat(InsertChat event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    final res = await _chatRepository.insertChat(
      name: event.name,
      isGroup: event.isGroup,
      imageUrl: event.imageUrl,
    );
    res.fold(
      (l) => emit(ChatFailure(message: l.message)),
      (r) => emit(ChatInsertSuccess(chat: r)),
    );
  }

  void _onInsertChatMembers(
      InsertChatMembers event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    final res = await _chatRepository.insertChatMembers(
      id: event.id,
      userId: event.userId,
    );
    res.fold(
      (l) => emit(ChatFailure(message: l.message)),
      (r) => emit(ChatInsertMembersSuccess()),
    );
  }

  void _onGetChatHeads(GetChatHeads event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    final res = await _chatRepository.getChatHeads(
      userId: event.userId,
    );
    res.fold(
      (l) => emit(ChatFailure(message: l.message)),
      (r) => emit(ChatsLoadedSuccess(chatHeads: r)),
    );
  }
}
