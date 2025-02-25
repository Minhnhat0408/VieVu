part of 'chat_bloc.dart';

@immutable
sealed class ChatEvent {}

final class InsertChat extends ChatEvent {
  final String? name;
  final String? imageUrl;
  final String? tripId;

  InsertChat({
    this.name,
    this.imageUrl,
    this.tripId,
  });
}

final class InsertChatMembers extends ChatEvent {
  final int id;
  final String userId;

  InsertChatMembers({
    required this.id,
    required this.userId,
  });
}

final class DeleteChat extends ChatEvent {
  final int id;

  DeleteChat({
    required this.id,
  });
}

final class GetChatHeads extends ChatEvent {}

final class ListenToUpdateChannels extends ChatEvent {}
