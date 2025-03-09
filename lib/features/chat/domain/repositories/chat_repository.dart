import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/features/auth/domain/entities/user.dart'
    as my_user;
import 'package:vn_travel_companion/features/chat/domain/entities/chat.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/features/chat/domain/entities/message.dart';

abstract interface class ChatRepository {
  Future<Either<Failure, Chat>> insertChat({
    String? name,
    String? tripId,
    String? userId,
    String? imageUrl,
  });

    Future<Either<Failure, Chat?>> getSingleChat({
    String? userId,
    String? tripId,
  });

  Future<Either<Failure, Unit>> insertChatMembers({
    required int id,
    required String userId,
  });

  Future deleteChat({
    required int id,
  });

  Future<Either<Failure, List<Chat>>> getChatHeads();

  RealtimeChannel listenToUpdateChannels({
    required Function(Message?) callback,
  });

  Future<Either<Failure, ChatSummarize>> summarizeItineraries({
    required int chatId,
  });

  RealtimeChannel listenToChatMembersChannel({
    required int chatId,
    required Function callback,
  });

  Future<Either<Failure, List<Map<int, my_user.User>>>> getSeenUser({
    required int chatId,
  });

  void unSubcribeToChatMembersChannel({
    required String channelName,
  });

  Future<Either<Failure, ChatSummarize?>> getCurrentChatSummary({
    required int chatId,
  });
  Future<Either<Failure, ChatSummarize>> createItineraryFromSummary({
    required int chatId,
  });
}
