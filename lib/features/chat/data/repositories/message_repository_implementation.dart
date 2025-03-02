import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/core/network/connection_checker.dart';
import 'package:vn_travel_companion/features/chat/data/datasources/message_remote_datasource.dart';
import 'package:vn_travel_companion/features/chat/domain/entities/message.dart';
import 'package:vn_travel_companion/features/chat/domain/repositories/message_repository.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageRemoteDatasource messageRemoteDatasource;
  final ConnectionChecker connectionChecker;

  MessageRepositoryImpl(this.messageRemoteDatasource, this.connectionChecker);

  @override
  Future<Either<Failure, Message>> insertMessage({
    required int chatId,
    required String message,
    List<Map<String, dynamic>>? metaData,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final res = await messageRemoteDatasource.insertMessage(
        chatId: chatId,
        message: message,
        metaData: metaData,
      );
      return right(res);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateSeenMessage({
    required int chatId,
    required int messageId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      await messageRemoteDatasource.updateSeenMessage(
        chatId: chatId,
        messageId: messageId,
      );
      return right(unit);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getMessagesInChat({
    required int chatId,
    required int limit,
    required int offset,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final res = await messageRemoteDatasource.getMessagesInChat(
        chatId: chatId,
        limit: limit,
        offset: offset,
      );
      return right(res);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateMessage({
    required int messageId,
    String? content,
    List<Map<String, dynamic>>? metaData,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      await messageRemoteDatasource.updateMessage(
        messageId: messageId,
        content: content,
        metaData: metaData,
      );
      return right(unit);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  RealtimeChannel listenToMessageUpdateChannel({
    required int chatId,
    required Function(Map<String, dynamic>) callback,
  }) {
    return messageRemoteDatasource.listenToMessageUpdateChannel(
      callback: callback,
      chatId: chatId,
    );
  }

  @override
  RealtimeChannel listenToMessagesChannel({
    required int chatId,
    required Function(Message?) callback,
  }) {
    return messageRemoteDatasource.listenToMessagesChannel(
      callback: callback,
      chatId: chatId,
    );
  }

  @override
  void unSubcribeToMessagesChannel({
    required String channelName,
  }) {
    messageRemoteDatasource.unSubcribeToMessagesChannel(
        channelName: channelName);
  }

  @override
  Future<Either<Failure, MessageReaction>> insertReaction({
    required int messageId,
    required String reaction,
    required int chatId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final res = await messageRemoteDatasource.insertReaction(
        messageId: messageId,
        reaction: reaction,
        chatId: chatId,
      );
      return right(res);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeReaction({
    required int messageId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      await messageRemoteDatasource.removeReaction(
        messageId: messageId,
      );
      return right(unit);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  RealtimeChannel listenToMessageReactionChannel({
    required int chatId,
    required Function({
      MessageReaction? messageReaction,
      required int reactionId,
      required String eventType,
    }) callback,
  }) {
    return messageRemoteDatasource.listenToMessageReactionChannel(
      callback: callback,
      chatId: chatId,
    );
  }
}
