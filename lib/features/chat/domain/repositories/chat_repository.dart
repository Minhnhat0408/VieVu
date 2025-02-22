import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/features/chat/domain/entities/chat.dart';
abstract interface class ChatRepository {
  Future<Either<Failure, Chat>> insertChat({
    String? name,
    required bool isGroup,
    String? imageUrl,
  });

  Future<Either<Failure, Unit>> insertChatMembers({
    required int id,
    required String userId,
  });

  Future deleteChat({
    required int id,
  });

  Future<Either<Failure,List<Chat>>> getChatHeads({
    required String userId,
  });
}
