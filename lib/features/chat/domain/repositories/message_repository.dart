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

  void unSubcribeToMessagesChannel({
    required String channelName,
  });
}
