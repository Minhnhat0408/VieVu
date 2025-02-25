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
final class MessageReceived extends MessageEvent {
  final Message message;

  MessageReceived({
    required this.message,
  });
}

final class UnSubcribeToMessagesChannel extends MessageEvent {
  final String channelName;

  UnSubcribeToMessagesChannel({
    required this.channelName,
  });
}
