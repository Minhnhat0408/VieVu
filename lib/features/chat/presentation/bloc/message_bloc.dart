import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/features/chat/domain/entities/message.dart';
import 'package:vn_travel_companion/features/chat/domain/repositories/message_repository.dart';

part 'message_event.dart';
part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final MessageRepository _messageRepository;
  MessageBloc({
    required MessageRepository messageRepository,
  })  : _messageRepository = messageRepository,
        super(MessageInitial()) {
    on<InsertMessage>(_onInsertMessage);
    on<ListenToMessagesChannel>(_onListenToMessagesChannel);
    on<UnSubcribeToMessagesChannel>(_onUnSubcribeToMessagesChannel);
    on<GetMessagesInChat>(_onGetMessagesInChat);
    on<MessageReceived>(_onMessageReceived);
    on<UpdateSeenMessage>(_onUpdateSeenMessage);
  }

  void _onInsertMessage(InsertMessage event, Emitter<MessageState> emit) async {
    emit(MessageLoading());
    final res = await _messageRepository.insertMessage(
      message: event.message,
      metaData: event.metaData,
      chatId: event.chatId,
    );
    res.fold(
      (l) => emit(MessageFailure(message: l.message)),
      (r) => emit(MessageInsertSuccess(message: r)),
    );
  }

  void _onUpdateSeenMessage(
      UpdateSeenMessage event, Emitter<MessageState> emit) async {
    emit(MessageLoading());
    await _messageRepository.updateSeenMessage(
      chatId: event.chatId,
      messageId: event.messageId,
    );
  }

  void _onGetMessagesInChat(
      GetMessagesInChat event, Emitter<MessageState> emit) async {
    emit(MessageLoading());
    final res = await _messageRepository.getMessagesInChat(
      chatId: event.chatId,
      limit: event.limit,
      offset: event.offset,
    );
    res.fold(
      (l) => emit(MessageFailure(message: l.message)),
      (r) => emit(MessagesLoadedSuccess(messages: r)),
    );
  }

  void _onListenToMessagesChannel(
      ListenToMessagesChannel event, Emitter<MessageState> emit) {
    _messageRepository.listenToMessagesChannel(
      chatId: event.chatId,
      callback: (payload) {
        if (payload != null) add(MessageReceived(message: payload));
      },
    );
  }

  void _onUnSubcribeToMessagesChannel(
      UnSubcribeToMessagesChannel event, Emitter<MessageState> emit) {
    _messageRepository.unSubcribeToMessagesChannel(
      channelName: event.channelName,
    );
  }

  void _onMessageReceived(
      MessageReceived event, Emitter<MessageState> emit) async {
    emit(MessageInsertSuccess(message: event.message));
  }
}
