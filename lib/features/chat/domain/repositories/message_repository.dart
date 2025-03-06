import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/features/chat/domain/entities/message.dart';

abstract interface class MessageRepository {
  Future<Either<Failure, Message>> insertMessage({
    required int chatId,
    required String message,
    List<Map<String, dynamic>>? metaData,
  });

  Future<Either<Failure, Unit>> updateSeenMessage({
    required int chatId,
    required int messageId,
  });

  Future<Either<Failure, Unit>> updateMessage({
    required int messageId,
    String? content,
    List<Map<String, dynamic>>? metaData,
  });

  Future<Either<Failure, List<Message>>> getMessagesInChat({
    required int chatId,
    required int limit,
    required int offset,
  });

  RealtimeChannel listenToMessagesChannel({
    required int chatId,
    required Function(Message?) callback,
  });

  RealtimeChannel listenToMessageUpdateChannel({
    required int chatId,
    required Function(Map<String, dynamic>) callback,
  });

  Future<Either<Failure, MessageReaction>> insertReaction({
    required int messageId,
    required String reaction,
    required int chatId,
  });

  RealtimeChannel listenToMessageReactionChannel({
    required int chatId,
    required Function({
      MessageReaction? messageReaction,
      required int reactionId,
      required String eventType,
    }) callback,
  });

  void unSubcribeToMessagesChannel({
    required String channelName,
  });

  Future<Either<Failure, Unit>> removeReaction({
    required int messageId,
  });

  Future<Either<Failure, Message>> removeMessage({
    required int messageId,
  });
  Future<Either<Failure, List<Message>>> getScrollToMessages({
    required int chatId,
    required int messageId,
    required int lastMessageId,
  });
}
