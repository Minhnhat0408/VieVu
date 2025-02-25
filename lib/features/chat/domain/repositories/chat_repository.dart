import 'package:fpdart/fpdart.dart';
import 'package:vn_travel_companion/core/error/failures.dart';
import 'package:vn_travel_companion/features/chat/domain/entities/chat.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/features/chat/domain/entities/message.dart';

abstract interface class ChatRepository {
  Future<Either<Failure, Chat>> insertChat({
    String? name,
    String? tripId,
    String? imageUrl,
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
}
