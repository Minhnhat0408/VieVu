part of 'chat_bloc.dart';

@immutable
sealed class ChatEvent {}

final class InsertChat extends ChatEvent {
  final String? name;
  final String? imageUrl;
  final String? userId;
  final String? tripId;

  InsertChat({
    this.name,
    this.userId,
    this.imageUrl,
    this.tripId,
  });
}

final class InsertChatMembers extends ChatEvent {
  final int?  chatId;
  final String? tripId;
  final String userId;

  InsertChatMembers({
    required this.chatId,
    required this.tripId,
    required this.userId,
  });
}

final class GetSingleChat extends ChatEvent {
  final String? userId;
  final String? tripId;

  GetSingleChat({
    this.userId,
    this.tripId,
  });
}

final class DeleteChat extends ChatEvent {
  final int id;

  DeleteChat({
    required this.id,
  });
}

final class GetChatHeads extends ChatEvent {}

final class SummarizeItineraries extends ChatEvent {
  final int chatId;

  SummarizeItineraries({
    required this.chatId,
  });
}

final class ListenToUpdateChannels extends ChatEvent {
  final int chatMemberId;

  ListenToUpdateChannels({
    required this.chatMemberId,
  });
}

final class ListenToChatMembersChannel extends ChatEvent {
  final int chatId;

  ListenToChatMembersChannel({
    required this.chatId,
  });
}

final class ListenToChatSummariesChannel extends ChatEvent {
  final int chatId;

  ListenToChatSummariesChannel({
    required this.chatId,
  });
}

final class GetSeenUser extends ChatEvent {
  final int chatId;

  GetSeenUser({
    required this.chatId,
  });
}

final class UnSubcribeToChannel extends ChatEvent {
  final String channelName;

  UnSubcribeToChannel({
    required this.channelName,
  });
}

final class GetChatSummary extends ChatEvent {
  final int chatId;

  GetChatSummary({
    required this.chatId,
  });
}

final class CreateItineraryFromSummary extends ChatEvent {
  final int chatId;

  CreateItineraryFromSummary({
    required this.chatId,
  });
}


final class ChatSummarizeReceived extends ChatEvent {
  final ChatSummarize chatSummarize;

  ChatSummarizeReceived({
    required this.chatSummarize,
  });
}
