import 'dart:developer';

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
import 'package:vn_travel_companion/features/explore/data/datasources/location_remote_datasource.dart';
import 'package:vn_travel_companion/features/trips/data/datasources/saved_service_remote_datasource.dart';
import 'package:vn_travel_companion/features/trips/data/datasources/trip_itinerary_remote_datasource.dart';

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
        name: name,
        tripId: tripId,
        imageUrl: imageUrl,
        userId: userId,
      );
      return right(res);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> insertChatMembers({
    required String id,
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
              final loc =
                  await locationRemoteDatasource.convertAddressToLatLng(
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
}


// [
//   {
//     "day": "2025-02-15",
//     "events": [
//       {
//         "note": "Tập trung tại điểm hẹn",
//         "time": "2025-02-15T08:00:00",
//         "place": "83 Xã đàn",
//         "metaData": {
//           "type": "address",
//           "title": "83 Xã đàn"
//         }
//       },
//       {
//         "note": "Khám phá vẻ đẹp lịch sử và văn hóa",
//         "time": "2025-02-15T10:00:00",
//         "place": "Bảo tàng Hà Nội",
//         "metaData": {
//           "id": 23032412,
//           "type": "attractions",
//           "cover": "https://ak-d.tripcdn.com/images/0ww2112000chq12qm7061.jpg",
//           "price": null,
//           "title": "Bảo tàng Hà Nội",
//           "address": "Phạm Hùng, Mễ Trì, Nam Từ Liêm, Hà Nội 100000, Việt Nam",
//           "isSaved": true,
//           "hotScore": 3.9,
//           "latitude": 21.009923,
//           "avgRating": 4.3,
//           "longitude": 105.786302,
//           "ratingCount": 17,
//           "externalLink": null,
//           "locationName": "Hà Nội"
//         }
//       },
//       {
//         "note": "Thưởng thức ẩm thực Hà Nội",
//         "time": "2025-02-15T12:00:00",
//         "place": "Old Hanoi Restaurant",
//         "metaData": {
//           "id": 17040314,
//           "type": "restaurant",
//           "cover": "https://ak-d.tripcdn.com/images/0101u12000d5zlbzh03DB_R_300_300_R5.jpg?proc=namelogo/d_1",
//           "price": null,
//           "title": "Old Hanoi Restaurant",
//           "address": "Hà Nội · Việt Nam",
//           "isSaved": true,
//           "hotScore": null,
//           "avgRating": 3.7,
//           "ratingCount": 12,
//           "externalLink": "https://vn.trip.com/travel-guide/hanoi-181-restaurant/old-hanoi-restaurant-17040314/",
//           "locationName": null
//         }
//       },
//       {
//         "note": "Tham quan kiến trúc cổ kính",
//         "time": "2025-02-15T15:00:00",
//         "place": "Nhà Thờ Lớn Hà Nội",
//         "metaData": {
//           "id": 90605,
//           "type": "attractions",
//           "cover": "https://ak-d.tripcdn.com/images/1A0u1b000001a1jcg96FA.jpg",
//           "price": null,
//           "title": "Nhà Thờ Lớn Hà Nội",
//           "address": "40 P. Nhà Chung, Hàng Trống, Hoàn Kiếm, Hà Nội 100000, Việt Nam",
//           "isSaved": true,
//           "hotScore": 6.1,
//           "latitude": 21.028841,
//           "avgRating": 4.6,
//           "longitude": 105.849119,
//           "ratingCount": 632,
//           "externalLink": null,
//           "locationName": "Hà Nội"
//         }
//       },
//       {
//         "note": "Thưởng thức bữa tối ngon miệng",
//         "time": "2025-02-15T19:00:00",
//         "place": "The Gourmet Corner",
//         "metaData": {
//           "id": 490639,
//           "type": "restaurant",
//           "cover": "https://ak-d.tripcdn.com/images/10030n000000e3h39D957_R_300_300_R5.jpg?proc=namelogo/d_1",
//           "price": null,
//           "title": "The Gourmet Corner",
//           "address": "Hà Nội · Việt Nam",
//           "isSaved": true,
//           "hotScore": null,
//           "avgRating": 4.4,
//           "ratingCount": 14,
//           "externalLink": "https://vn.trip.com/travel-guide/hanoi-181-restaurant/the-gourmet-corner-490639/",
//           "locationName": null
//         }
//       }
//     ]
//   },
//   {
//     "day": "2025-02-16",
//     "events": [
//       {
//         "note": "Bắt đầu hành trình đến Tuyên Quang",
//         "time": "2025-02-16T08:00:00",
//         "place": "Tuyên Quang",
//         "metaData": {
//           "id": 1524609,
//           "type": "locations",
//           "cover": "https://ak-d.tripcdn.com/images/0ww2d12000ckt13iw1DB3_D_1180_558.jpg",
//           "price": null,
//           "title": "Tuyên Quang",
//           "address": null,
//           "isSaved": true,
//           "hotScore": null,
//           "latitude": 22.17267,
//           "avgRating": null,
//           "longitude": 105.31312,
//           "ratingCount": null,
//           "externalLink": null,
//           "locationName": "Tuyên Quang"
//         }
//       },
//       {
//         "note": "Nhận phòng và nghỉ ngơi",
//         "time": "2025-02-16T13:00:00",
//         "place": "Royal Palace Hotel Tuyên Quang",
//         "metaData": {
//           "id": 7596074,
//           "type": "hotel",
//           "cover": "https://dimg11.c-ctrip.com/images/02264120009t55yit07C1_R_300_300_R5.jpg?proc=namelogo/d_1",
//           "price": null,
//           "title": "Royal Palace Hotel Tuyên Quang",
//           "address": "Tuyên Quang, Tuyên Quang, Việt Nam",
//           "isSaved": true,
//           "hotScore": null,
//           "avgRating": 4.5,
//           "ratingCount": 31,
//           "externalLink": "/hotels/tuyen-quang-hotel-detail-7596074/royal-palace-hotel/",
//           "locationName": null
//         }
//       },
//       {
//         "note": "Ngắm cảnh đẹp tự nhiên",
//         "time": "2025-02-16T17:00:00",
//         "place": "Thác Khuổi Nhi",
//         "metaData": {
//           "id": 137058151,
//           "type": "attractions",
//           "cover": "https://lh5.googleusercontent.com/p/AF1QipM7gT_Hgdj48wnu6ihcbTgI-YipgUqa6Ir8REng=w122-h92-k-no",
//           "price": null,
//           "title": "Thác Khuổi Nhi",
//           "address": "F9PF+2V5, Thượng Lâm, Na Hang, Tuyên Quang, Việt Nam",
//           "isSaved": true,
//           "hotScore": 2.5,
//           "latitude": 22.485012,
//           "avgRating": 4,
//           "longitude": 105.374725,
//           "ratingCount": 326,
//           "externalLink": null,
//           "locationName": "Tuyên Quang"
//         }
//       }
//     ]
//   },
//   {
//     "day": "2025-02-17",
//     "events": []
//   },
//   {
//     "day": "2025-02-18",
//     "events": []
//   }
// ]
