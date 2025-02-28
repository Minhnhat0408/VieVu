import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/auth/domain/entities/user.dart';
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
    on<SummarizeItineraries>(_onSummarizeItineraries);
    on<GetChatHeads>(_onGetChatHeads);
    on<ListenToUpdateChannels>(_onListenToUpdateChannels);
    on<ListenToChatMembersChannel>(_onListenToChatMembersChannel);
    on<GetSeenUser>(_onGetSeenUser);
    on<UnSubcribeToChatMembersChannel>(_onUnSubcribeToChatMembersChannel);
    on<GetChatSummary>(_onGetChatSummary);
  }

  void _onUnSubcribeToChatMembersChannel(
      UnSubcribeToChatMembersChannel event, Emitter<ChatState> emit) async {
    _chatRepository.unSubcribeToChatMembersChannel(
      channelName: event.channelName,
    );
  }

  void _onInsertChat(InsertChat event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    final res = await _chatRepository.insertChat(
      name: event.name,
      imageUrl: event.imageUrl,
      tripId: event.tripId,
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
    final res = await _chatRepository.getChatHeads();
    res.fold(
      (l) => emit(ChatFailure(message: l.message)),
      (r) => emit(ChatsLoadedSuccess(chatHeads: r)),
    );
  }

  void _onListenToUpdateChannels(
      ListenToUpdateChannels event, Emitter<ChatState> emit) async {
    _chatRepository.listenToUpdateChannels(
      callback: (message) {
        add(GetChatHeads());
      },
    );
  }

  void _onSummarizeItineraries(
      SummarizeItineraries event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    final res = await _chatRepository.summarizeItineraries(
      chatId: event.chatId,
    );
    res.fold(
      (l) => emit(ChatFailure(message: l.message)),
      (r) => emit(ChatSummarizedSuccess(chatSummarize: r)),
    );
  }

  void _onListenToChatMembersChannel(
      ListenToChatMembersChannel event, Emitter<ChatState> emit) async {
    _chatRepository.listenToChatMembersChannel(
      chatId: event.chatId,
      callback: () {
        add(GetSeenUser(chatId: event.chatId));
      },
    );
  }

  void _onGetSeenUser(GetSeenUser event, Emitter<ChatState> emit) async {
    final res = await _chatRepository.getSeenUser(
      chatId: event.chatId,
    );
    res.fold(
      (l) => emit(ChatFailure(message: l.message)),
      (r) => emit(SeenUpdatedSuccess(seenUser: r)),
    );
  }

  void _onGetChatSummary(GetChatSummary event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    final res = await _chatRepository.getCurrentChatSummary(
      chatId: event.chatId,
    );
    res.fold(
      (l) => emit(ChatFailure(message: l.message)),
      (r) => emit(ChatSummarizedSuccess(chatSummarize: r)),
    );
  }
}
