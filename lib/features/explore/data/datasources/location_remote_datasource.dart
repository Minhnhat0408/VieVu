import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/features/explore/data/models/attraction_model.dart';
import 'package:vn_travel_companion/features/explore/data/models/hotel_model.dart';
import 'package:vn_travel_companion/features/explore/data/models/location_model.dart';
import 'package:vn_travel_companion/features/explore/data/models/restaurant_model.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/comment.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/location.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/tripbest.dart';

abstract interface class LocationRemoteDatasource {
  Future<LocationModel?> getLocation({
    required int locationId,
  });

  Future<List<LocationModel>> getHotLocations({
    required int limit,
    required int offset,
  });

  // Future<List<LocationModel>> getAttractionsByCategory({
  //   required String category,
  //   required int limit,
  //   required int offset,
  // });

  Future<List<LocationModel>> getRecentViewedLocations({
    required int limit,
  });

  Future upsertRecentViewedLocations({
    required int locationId,
    required String userId,
  });

  Future<GenericLocationInfo> getLocationGeneralInfo({
    required int locationId,
  });
}

class LocationRemoteDatasourceImpl implements LocationRemoteDatasource {
  final SupabaseClient supabaseClient;

  LocationRemoteDatasourceImpl(
    this.supabaseClient,
  );

  @override
  Future<LocationModel?> getLocation({
    required int locationId,
  }) async {
    try {
      final response = await supabaseClient
          .from('locations')
          .select('*, parent:parent_id(name, id, parent_id)')
          .eq('id', locationId)
          .maybeSingle();

      log(response.toString());
      if (response == null) {
        return null;
      }

      final address = [];
      if (response['parent'] != null) {
        address.add(response['parent']['name']);
        final subParentId = response['parent']['parent_id'];
        if (subParentId != null) {
          final subParentResponse = await supabaseClient
              .from('locations')
              .select('*, parent:parent_id(name, id, parent_id)')
              .eq('id', subParentId)
              .maybeSingle();

          address.add(subParentResponse!['name']);
        }
      }
      address.add('Việt Nam');
      final cleanAddress = address.join(', ');

      return LocationModel.fromJson(response).copyWith(address: cleanAddress);
    } catch (e) {
      log(e.toString());

      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<LocationModel>> getHotLocations({
    required int limit,
    required int offset,
  }) async {
    try {
      final response = await supabaseClient
          .from('locations')
          .select('*')
          .order('created_at', ascending: true)
          .range(offset, offset + limit);

      return response.map((e) => LocationModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<LocationModel>> getRecentViewedLocations({
    required int limit,
  }) async {
    try {
      final response = await supabaseClient
          .from('viewed_history')
          .select('*, locations(*)')
          .order('created_at', ascending: false)
          .range(0, limit);

      return response
          .map((e) => LocationModel.fromJson(e['locations']))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future upsertRecentViewedLocations({
    required int locationId,
    required String userId,
  }) async {
    try {
      await supabaseClient.from('viewed_history').upsert({
        'user_id': userId,
        'location_id': locationId,
        'viewed_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<GenericLocationInfo> getLocationGeneralInfo({
    required int locationId,
  }) async {
    final url = Uri.parse(
        'https://www.trip.com/restapi/soa2/23044/getDestinationPageInfo.json');
    final body = {
      "districtId": locationId,
      "moduleList": [
        "hotComment",
        "hotDistrict",
        "tripBestRank",
        "classicRecommendSight",
        "classicRecommendHotel",
        "classicRecommendRestaurant"
      ],
      "head": {
        "syscode": "10000",
        "lang:": "vi-VN",
        "extension": [
          {"name": "locale", "value": "vi-VN"},
          {"name": "platform", "value": "Online"},
          {"name": "currency", "value": "VND"},
          {
            "name": "userAgent",
            "value":
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36"
          }
        ]
      }
    };
    try {
      final response = await http.post(
        url,
        body: jsonEncode(body),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final data = jsonResponse['moduleList'] as List<dynamic>;
        final returnData = GenericLocationInfo(
          attractions: [],
          hotels: [],
          restaurants: [],
        );
        for (final item in data) {
          if (item['typeName'] == 'hotComment') {
            log('hotComment');
            returnData.comments =
                (item['hotCommentModule']['hotCommentList'] as List)
                    .map((e) => Comment.fromJson(e))
                    .toList();
          } else if (item['typeName'] == 'classicRecommendSight') {
            log('classicRecommendSight');
            returnData.attractions = (item['classicRecommendSightModule']
                    ['sightList'][0]['sightList'] as List)
                .map((e) => AttractionModel.fromGeneralLocationInfo(e))
                .toList();
          } else if (item['typeName'] == 'classicRecommendHotel') {
            log('classicRecommendHotel');
            returnData.hotels = (item['classicRecommendHotelModule']
                    ['hotelList'][0]['hotelList'] as List)
                .map((e) => HotelModel.fromGeneralLocationInfo(e))
                .toList();
          } else if (item['typeName'] == 'classicRecommendRestaurant') {
            log('classicRecommendRestaurant');

            returnData.restaurants = (item['classicRecommendRestaurantModule']
                    ['restaurantList'][0]['restaurantList'] as List)
                .map((e) => RestaurantModel.fromGeneralLocationInfo(e))
                .toList();
          } else if (item['typeName'] == 'tripBestRank') {
            log('tripBestRank');
            returnData.tripbestModule = (item['tripBestRankingInfoModule']
                    ['rankgingInfoTabList'] as List)
                .map((e) => TripBest.fromJson(e))
                .toList();
          }
        }
        return returnData;
      } else {
        throw ServerException(response.body);
      }
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }
}
