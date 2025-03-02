part of 'message_bloc.dart';

@immutable
sealed class MessageState {}

final class MessageInitial extends MessageState {}


final class MessageLoading extends MessageState {}

final class MessagesLoadedSuccess extends MessageState {
  final List<Message> messages;

  MessagesLoadedSuccess({
    required this.messages,
  });
}


final class MessageInsertSuccess extends MessageState {
  final Message message;

  MessageInsertSuccess({
    required this.message,
  });
}


final class MessageFailure extends MessageState {
  final String message;

  MessageFailure({
    required this.message,
  });
}


final class MessageUpdateReceivedSuccess extends MessageState {
  final Map<String, dynamic> message;

  MessageUpdateReceivedSuccess({
    required this.message,
  });
}

final class MessageReactionSuccess extends MessageState {
  final String eventType;
  final MessageReaction? reaction;

  MessageReactionSuccess({
    required this.reaction,
    required this.eventType,

  });
}

