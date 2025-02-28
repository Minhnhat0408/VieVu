import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/core/network/connection_checker.dart';
import 'package:vn_travel_companion/features/auth/domain/entities/user.dart'
    as my_user;
import 'package:vn_travel_companion/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:vn_travel_companion/features/chat/data/datasources/message_remote_datasource.dart';
import 'package:vn_travel_companion/features/chat/domain/entities/chat.dart';
import 'package:vn_travel_companion/features/chat/domain/entities/message.dart';
import 'package:vn_travel_companion/features/chat/domain/repositories/chat_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDatasource chatRemoteDatasource;
  final MessageRemoteDatasource messageRemoteDatasource;
  final ConnectionChecker connectionChecker;

  ChatRepositoryImpl({
    required this.chatRemoteDatasource,
    required this.messageRemoteDatasource,
    required this.connectionChecker,
  });

  @override
  Future<Either<Failure, Chat>> insertChat({
    String? name,
    String? tripId,
    String? imageUrl,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final res = await chatRemoteDatasource.insertChat(
        name: name,
        tripId: tripId,
        imageUrl: imageUrl,
      );
      return right(res);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> insertChatMembers({
    required int id,
    required String userId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      await chatRemoteDatasource.insertChatMembers(
        id: id,
        userId: userId,
      );
      return right(unit);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future deleteChat({
    required int id,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final res = await chatRemoteDatasource.deleteChat(
        id: id,
      );
      return right(res);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Chat>>> getChatHeads() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final res = await chatRemoteDatasource.getChatHeads();
      return right(res);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  RealtimeChannel listenToUpdateChannels({
    required Function(Message?) callback,
  }) {
    return messageRemoteDatasource.listenToMessagesChannel(
      callback: callback,
    );
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> summarizeItineraries({
    required int chatId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final res = await chatRemoteDatasource.summarizeItineraries(
        chatId: chatId,
      );
      return right(res);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  RealtimeChannel listenToChatMembersChannel({
    required int chatId,
    required Function callback,
  }) {
    return chatRemoteDatasource.listenToChatMembersChannel(
      chatId: chatId,
      callback: callback,
    );
  }

  @override
  Future<Either<Failure, List<Map<int, my_user.User>>>> getSeenUser({
    required int chatId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final res = await chatRemoteDatasource.getSeenUser(
        chatId: chatId,
      );
      return right(res);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }


  @override
  void unSubcribeToChatMembersChannel({
    required String channelName,
  }) {
    chatRemoteDatasource.unSubcribeToChatMembersChannel(
      channelName: channelName,
    );
  }
}
