import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/core/network/connection_checker.dart';
import 'package:vn_travel_companion/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:vn_travel_companion/features/chat/domain/entities/chat.dart';
import 'package:vn_travel_companion/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDatasource chatRemoteDatasource;
  final ConnectionChecker connectionChecker;

  ChatRepositoryImpl(this.chatRemoteDatasource, this.connectionChecker);

  @override
  Future<Either<Failure, Chat>> insertChat({
    String? name,
    required bool isGroup,
    String? imageUrl,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final res = await chatRemoteDatasource.insertChat(
        name: name,
        isGroup: isGroup,
        imageUrl: imageUrl,
      );
      return right(res);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure,Unit>> insertChatMembers({
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
  Future<Either<Failure, List<Chat>>> getChatHeads({
    required String userId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final res = await chatRemoteDatasource.getChatHeads(
        userId: userId,
      );
      return right(res);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
