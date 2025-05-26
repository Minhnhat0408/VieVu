
import 'package:fpdart/fpdart.dart';
import 'package:vievu/core/error/exceptions.dart';
import 'package:vievu/core/error/failures.dart';
import 'package:vievu/core/network/connection_checker.dart';
import 'package:vievu/features/auth/domain/entities/user.dart' as my_user;
import 'package:vievu/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:vievu/features/chat/data/datasources/message_remote_datasource.dart';
import 'package:vievu/features/chat/domain/entities/chat.dart';
import 'package:vievu/features/chat/domain/entities/message.dart';
import 'package:vievu/features/chat/domain/repositories/chat_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vievu/features/explore/data/datasources/location_remote_datasource.dart';
import 'package:vievu/features/trips/data/datasources/saved_service_remote_datasource.dart';
import 'package:vievu/features/trips/data/datasources/trip_itinerary_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDatasource chatRemoteDatasource;
  final MessageRemoteDatasource messageRemoteDatasource;
  final ConnectionChecker connectionChecker;
  final SavedServiceRemoteDatasource savedServiceRemoteDatasource;
  final TripItineraryRemoteDatasource tripItineraryRemoteDatasource;
  final LocationRemoteDatasource locationRemoteDatasource;

  ChatRepositoryImpl({
    required this.chatRemoteDatasource,
    required this.messageRemoteDatasource,
    required this.connectionChecker,
    required this.savedServiceRemoteDatasource,
    required this.tripItineraryRemoteDatasource,
    required this.locationRemoteDatasource,
  });

  @override
  RealtimeChannel listenToChatSummariesChannel({
    required int chatId,
    required Function(ChatSummarize) callback,
  }) {
    return chatRemoteDatasource.listenToChatSummariesChannel(
      chatId: chatId,
      callback: callback,
    );
  }

  @override
  Future<Either<Failure, Chat?>> getSingleChat({
    String? userId,
    String? tripId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }

      final res = await chatRemoteDatasource.getSingleChat(
        userId: userId,
        tripId: tripId,
      );

      return right(res);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Chat>> insertChat({
    String? name,
    String? tripId,
    String? userId,
    String? imageUrl,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final res = await chatRemoteDatasource.insertChat(
        tripId: tripId,
        userId: userId,
      );

      return right(res);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> insertChatMembers({
    String? tripId,
    int? chatId,
    required String userId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      await chatRemoteDatasource.insertChatMembers(
        chatId: chatId,
        tripId: tripId,
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
        required int chatMemberId,
  }) {
    return messageRemoteDatasource.listenToMessagesChannel(
      callback: callback,
      chatMemberId: chatMemberId,
    );
  }

  @override
  Future<Either<Failure, ChatSummarize>> summarizeItineraries({
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
  void unSubcribeToChannel({
    required String channelName,
  }) {
    chatRemoteDatasource.unSubcribeToChannel(
      channelName: channelName,
    );
  }

  @override
  Future<Either<Failure, ChatSummarize?>> getCurrentChatSummary({
    required int chatId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final res = await chatRemoteDatasource.getCurrentChatSummary(
        chatId: chatId,
      );
      return right(res);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, ChatSummarize>> createItineraryFromSummary({
    required int chatId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      final chat = await chatRemoteDatasource.getCurrentChatSummary(
        chatId: chatId,
      );

      if (chat == null) {
        return left(Failure("Không tìm thấy lịch trình"));
      }

      final summary = chat.summary;
      for (var item in summary) {
        final itineraries = item['events'];

        for (var itinerary in itineraries) {
          if (itinerary['metaData']['isSaved'] != null &&
              itinerary['metaData']['isSaved'] == true) {
            final service =
                await savedServiceRemoteDatasource.getSavedServiceIdsForLinkid(
                    linkId: itinerary['metaData']['id'], tripId: chat.tripId);
            await tripItineraryRemoteDatasource.insertTripItinerary(
              tripId: chat.tripId,
              note: itinerary['note'],
              title: itinerary['place'],
              time: DateTime.parse(itinerary['time']),
              serviceId: service.dbId,
              latitude: service.latitude,
              longitude: service.longitude,
            );
          } else {
            if (itinerary['metaData']['type'] == 'address') {
              final res = await locationRemoteDatasource.convertAddressToLatLng(
                  address: itinerary['metaData']['title']);
              await tripItineraryRemoteDatasource.insertTripItinerary(
                tripId: chat.tripId,
                note: itinerary['note'],
                title: itinerary['place'],
                time: DateTime.parse(itinerary['time']),
                latitude: res.latitude,
                longitude: res.longitude,
              );
            } else if (itinerary['metaData']['type'] == 'name') {
              final loc = await locationRemoteDatasource.convertAddressToLatLng(
                  address: itinerary['metaData']['title']);
              await tripItineraryRemoteDatasource.insertTripItinerary(
                tripId: chat.tripId,
                note: itinerary['note'],
                title: itinerary['place'],
                time: DateTime.parse(itinerary['time']),
                latitude: loc.latitude,
                longitude: loc.longitude,
              );
            } else if (itinerary['metaData']['type'] == 'attractions' ||
                itinerary['metaData']['type'] == 'locations') {
              final res = await savedServiceRemoteDatasource.insertSavedService(
                tripId: chat.tripId,
                name: itinerary['metaData']['title'],
                linkId: itinerary['metaData']['id'],
                locationName: itinerary['metaData']['locationName'],
                cover: itinerary['metaData']['cover'],
                rating: itinerary['metaData']['avgRating'] ?? 0,
                ratingCount: itinerary['metaData']['ratingCount'] ?? 0,
                typeId: itinerary['metaData']['type'] == 'attractions' ? 2 : 0,
                latitude: itinerary['metaData']['latitude'],
                longitude: itinerary['metaData']['longitude'],
              );
              itinerary['metaData']['isSaved'] = true;
              itinerary['metaData']['id'] = res.id;
              await tripItineraryRemoteDatasource.insertTripItinerary(
                tripId: chat.tripId,
                note: itinerary['note'],
                title: itinerary['place'],
                serviceId: res.dbId,
                time: DateTime.parse(itinerary['time']),
                latitude: itinerary['metaData']['latitude'],
                longitude: itinerary['metaData']['longitude'],
              );
            } else if (itinerary['metaData']['type'] == 'restaurant' ||
                itinerary['metaData']['type'] == 'hotel') {
              final loc =
                  await locationRemoteDatasource.convertAddressToGeoLocation(
                      address: itinerary['metaData']['title']);
              final res = await savedServiceRemoteDatasource.insertSavedService(
                tripId: chat.tripId,
                name: itinerary['metaData']['title'],
                linkId: itinerary['metaData']['id'],
                locationName: loc.cityName,
                cover: itinerary['metaData']['cover'],
                rating: itinerary['metaData']['avgRating'] ?? 0,
                ratingCount: itinerary['metaData']['ratingCount'] ?? 0,
                typeId: itinerary['metaData']['type'] == 'restaurant' ? 1 : 4,
                latitude: loc.latitude,
                longitude: loc.longitude,
                externalLink: itinerary['metaData']['externalLink'],
                price: itinerary['metaData']['price'],
              );
              itinerary['metaData']['isSaved'] = true;
              itinerary['metaData']['id'] = res.id;
              await tripItineraryRemoteDatasource.insertTripItinerary(
                tripId: chat.tripId,
                note: itinerary['note'],
                title: itinerary['place'],
                serviceId: res.dbId,
                time: DateTime.parse(itinerary['time']),
                latitude: loc.latitude,
                longitude: loc.longitude,
              );
            } else if (itinerary['metaData']['type'] == 'event') {
              final loc = await locationRemoteDatasource.convertAddressToLatLng(
                  address: itinerary['metaData']['address']);
              final res = await savedServiceRemoteDatasource.insertSavedService(
                tripId: chat.tripId,
                name: itinerary['metaData']['title'],
                linkId: itinerary['metaData']['id'],
                locationName: itinerary['metaData']['locationName'],
                cover: itinerary['metaData']['cover'],
                rating: itinerary['metaData']['avgRating'] ?? 0,
                ratingCount: itinerary['metaData']['ratingCount'] ?? 0,
                typeId: 5,
                latitude: loc.latitude,
                eventDate:
                    DateTime.tryParse(itinerary['metaData']['eventDate']),
                longitude: loc.longitude,
                externalLink: itinerary['metaData']['externalLink'],
                price: itinerary['metaData']['price'],
              );
              itinerary['metaData']['isSaved'] = true;
              itinerary['metaData']['id'] = res.id;

              await tripItineraryRemoteDatasource.insertTripItinerary(
                tripId: chat.tripId,
                note: itinerary['note'],
                title: itinerary['place'],
                serviceId: res.dbId,
                time: DateTime.parse(itinerary['time']),
                latitude: loc.latitude,
                longitude: loc.longitude,
              );
            }
          }
        }
      }
      final summarize = await chatRemoteDatasource.updateSummarize(
        isConverted: true,
        chatId: chatId,
        metaData: summary,
      );
      return right(summarize);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateAvailableChatMember({
    required String tripId,
    required String userId,
    required bool available,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("Không có kết nối mạng"));
      }
      await chatRemoteDatasource.updateAvailableChatMember(
        tripId: tripId,
        userId: userId,
        available: available,
      );
      return right(unit);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
