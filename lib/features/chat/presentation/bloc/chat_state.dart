part of 'chat_bloc.dart';

@immutable
sealed class ChatState {}

final class ChatInitial extends ChatState {}

final class ChatLoading extends ChatState {}

final class ChatCreateTripItineraryLoading extends ChatState {}

final class ChatCreateTripItinerarySuccess extends ChatState {
  final ChatSummarize chatSummarize;

  ChatCreateTripItinerarySuccess({
    required this.chatSummarize,
  });
}

final class ChatLoadedSuccess extends ChatState {
  final Chat chat;

  ChatLoadedSuccess({
    required this.chat,
  });
}

final class ChatsLoadedSuccess extends ChatState {
  final List<Chat> chatHeads;

  ChatsLoadedSuccess({
    required this.chatHeads,
  });
}

final class ChatInsertSuccess extends ChatState {
  final Chat chat;

  ChatInsertSuccess({
    required this.chat,
  });
}

final class ChatInsertMembersSuccess extends ChatState {}

final class ChatDeleteSuccess extends ChatState {
  final int id;

  ChatDeleteSuccess({
    required this.id,
  });
}

final class ChatFailure extends ChatState {
  final String message;

  ChatFailure({
    required this.message,
  });
}

final class SummarizeItinerariesSuccess extends ChatState {
  final List<Map<String, dynamic>> itineraries;

  SummarizeItinerariesSuccess({
    required this.itineraries,
  });
}

final class SeenUpdatedSuccess extends ChatState {
  final List<Map<int, User>> seenUser;

  SeenUpdatedSuccess({
    required this.seenUser,
  });
}

final class ChatSummarizedSuccess extends ChatState {
  final ChatSummarize chatSummarize;

  ChatSummarizedSuccess({
    required this.chatSummarize,
  });
}

final class ChatSummarizeReceivedSuccess extends ChatState {
  final ChatSummarize chatSummarize;

  ChatSummarizeReceivedSuccess({
    required this.chatSummarize,
  });
}

final class ChatSummaryLoadedSuccess extends ChatState {
  final ChatSummarize? chatSummarize;

  ChatSummaryLoadedSuccess({
    this.chatSummarize,
  });
}
