part of 'message_bloc.dart';

@immutable
sealed class MessageEvent {}

final class InsertMessage extends MessageEvent {
  final List<Map<String, dynamic>>? metaData;
  final String message;
  final int chatId;

  InsertMessage({
    required this.message,
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

  ListenToMessagesChannel({
    required this.chatId,
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
  final String reaction;
  final int chatId;

  InsertReaction({
    required this.messageId,
    required this.chatId,
    required this.reaction,
  });
}

final class RemoveReaction extends MessageEvent {
  final int messageId;

  RemoveReaction({
    required this.messageId,
  });
}

final class ListenToMessageReactionChannel extends MessageEvent {
  final int chatId;

  ListenToMessageReactionChannel({
    required this.chatId,
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
