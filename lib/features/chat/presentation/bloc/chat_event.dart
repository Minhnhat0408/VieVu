part of 'chat_bloc.dart';

@immutable
sealed class ChatEvent {}

final class InsertChat extends ChatEvent {
  final String name;
  final bool isGroup;
  final String imageUrl;

  InsertChat({
    required this.name,
    required this.isGroup,
    required this.imageUrl,
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

final class GetChatHeads extends ChatEvent {
  final String userId;

  GetChatHeads({
    required this.userId,
  });
}
