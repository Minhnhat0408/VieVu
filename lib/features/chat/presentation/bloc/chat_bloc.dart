import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/features/auth/domain/entities/user.dart';
import 'package:vievu/features/chat/domain/entities/chat.dart';
import 'package:vievu/features/chat/domain/repositories/chat_repository.dart';

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
    on<UnSubcribeToChannel>(_onUnSubcribeToChannel);
    on<GetChatSummary>(_onGetChatSummary);
    on<CreateItineraryFromSummary>(_onCreateItineraryFromSummary);
    on<GetSingleChat>(_onGetSingleChat);
    on<ListenToChatSummariesChannel>(_onListenToChatSummariesChannel);
    on<UpdateAvailableChatMember>(_onUpdateAvailableChatMember);
  }

  void _onUnSubcribeToChannel(
      UnSubcribeToChannel event, Emitter<ChatState> emit) async {
    _chatRepository.unSubcribeToChannel(
      channelName: event.channelName,
    );
  }

  void _onListenToChatSummariesChannel(
      ListenToChatSummariesChannel event, Emitter<ChatState> emit) async {
    _chatRepository.listenToChatSummariesChannel(
      chatId: event.chatId,
      callback: (chatSummarize) {
        add(ChatSummarizeReceived(chatSummarize: chatSummarize));
      },
    );
  }

  void _onGetSingleChat(GetSingleChat event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    final res = await _chatRepository.getSingleChat(
      userId: event.userId,
      tripId: event.tripId,
    );
    res.fold((l) => emit(ChatFailure(message: l.message)), (r) {
      if (r != null) {
        emit(ChatLoadedSuccess(chat: r));
      } else {
        add(InsertChat(
          userId: event.userId,
        ));
      }
    });
  }

  void _onInsertChat(InsertChat event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    final res = await _chatRepository.insertChat(
      tripId: event.tripId,
      userId: event.userId,
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
      chatId: event.chatId,
      tripId: event.tripId,
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
      chatMemberId: event.chatMemberId,
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
      (l) => emit(ChatSummarizeFailure(message: l.message)),
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
      (r) => emit(ChatSummaryLoadedSuccess(chatSummarize: r)),
    );
  }

  void _onCreateItineraryFromSummary(
      CreateItineraryFromSummary event, Emitter<ChatState> emit) async {
    emit(ChatCreateTripItineraryLoading());
    final res = await _chatRepository.createItineraryFromSummary(
      chatId: event.chatId,
    );
    res.fold(
      (l) => emit(ChatSummarizeFailure(message: l.message)),
      (r) => emit(ChatCreateTripItinerarySuccess(chatSummarize: r)),
    );
  }

  void _onUpdateAvailableChatMember(
      UpdateAvailableChatMember event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    final res = await _chatRepository.updateAvailableChatMember(
      available: event.available,
      tripId: event.tripId,
      userId: event.userId,
    );
    res.fold(
      (l) => emit(ChatFailure(message: l.message)),
      (r) => emit(ChatMemberUpdatedAvailableSuccess(
        available: event.available,
      )),
    );
  }
}
