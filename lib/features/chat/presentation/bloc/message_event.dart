part of 'message_bloc.dart';

@immutable
sealed class MessageEvent {}

final class InsertMessage extends MessageEvent {
  final List<Map<String, dynamic>>? metaData;
  final String message;
  final int chatMemberId;
  final int chatId;

  InsertMessage({
    required this.message,
    required this.chatMemberId,
    this.metaData,
    required this.chatId,
  });
}

final class GetMessagesInChat extends MessageEvent {
  final int chatId;
  final int limit;
  final int offset;

  GetMessagesInChat({
    required this.chatId,
    required this.limit,
    required this.offset,
  });
}

final class ListenToMessagesChannel extends MessageEvent {
  final int chatId;
  final int chatMemberId;

  ListenToMessagesChannel({
    required this.chatId,
    required this.chatMemberId,
  });
}

final class UpdateSeenMessage extends MessageEvent {
  final int chatId;
  final int messageId;

  UpdateSeenMessage({
    required this.chatId,
    required this.messageId,
  });
}

final class UpdateMessageContent extends MessageEvent {
  final int messageId;
  final String? content;
  final List<Map<String, dynamic>>? metaData;

  UpdateMessageContent({
    required this.messageId,
    this.content,
    this.metaData,
  });
}

final class MessageReceived extends MessageEvent {
  final Message message;

  MessageReceived({
    required this.message,
  });
}

final class ListenToMessageUpdateChannel extends MessageEvent {
  final int chatId;

  ListenToMessageUpdateChannel({
    required this.chatId,
  });
}

final class MessageUpdateReceived extends MessageEvent {
  final Map<String, dynamic> message;

  MessageUpdateReceived({
    required this.message,
  });
}

final class UnSubcribeToMessagesChannel extends MessageEvent {
  final String channelName;

  UnSubcribeToMessagesChannel({
    required this.channelName,
  });
}

final class InsertReaction extends MessageEvent {
  final int messageId;
  final int chatMemberId;
  final String reaction;
  final int chatId;

  InsertReaction({
    required this.messageId,
    required this.chatId,
    required this.reaction,
    required this.chatMemberId,
  });
}

final class RemoveReaction extends MessageEvent {
  final int messageId;
  final int chatMemberId;

  RemoveReaction({
    required this.messageId,
    required this.chatMemberId,
  });
}

final class ListenToMessageReactionChannel extends MessageEvent {
  final int chatId;
  final int chatMemberId;

  ListenToMessageReactionChannel({
    required this.chatId,
    required this.chatMemberId,
  });
}

final class MessageReactionReceived extends MessageEvent {
  final String eventType;
  final MessageReaction? reaction;
  final int reactionId;

  MessageReactionReceived({
    this.reaction,
    required this.eventType,
    required this.reactionId,
  });
}

final class RemoveMessage extends MessageEvent {
  final int messageId;

  RemoveMessage({
    required this.messageId,
  });
}

final class GetScrollToMessages extends MessageEvent {
  final int chatId;
  final int messageId;
  final int lastMessageId;

  GetScrollToMessages({
    required this.lastMessageId,
    required this.chatId,
    required this.messageId,
  });
}
