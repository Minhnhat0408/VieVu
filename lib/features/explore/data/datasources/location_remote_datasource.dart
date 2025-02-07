import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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

  Future<List<LocationModel>> getRecentViewedLocations({
    required int limit,
  });

  Future upsertRecentViewedLocations({
    required int locationId,
    required String userId,
  });

  Future<dynamic> getLocationGeneralInfo({
    required int locationId,
    // required String locationName,
    // required String userId,
  });

  Future<GeoApiLocationModel> convertGeoLocationToAddress({
    required double latitude,
    required double longitude,
  });

  Future<GeoApiLocationModel> convertAddressToGeoLocation({
    required String address,
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

      final childLoc = await supabaseClient
          .from('locations')
          .select('*')
          .eq('parent_id', locationId)
          .limit(6)
          .order('cover', ascending: true);
      if (childLoc.isNotEmpty) {
        response['childLoc'] = childLoc.map((e) {
          log(e.toString());
          return LocationModel.fromJson(e);
        }).toList();
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
  Future<dynamic> getLocationGeneralInfo({
    required int locationId,
    // required String locationName,
    // required String userId,
  }) async {
    final url = Uri.parse(
        'https://www.trip.com/restapi/soa2/23044/getDestinationPageInfo.json');
    final body = {
      "districtId": locationId,
      "moduleList": [
        "hotComment",
        "hotDistrict",
        "tripBestRank",
        // "classicRecommendSight",
        // "classicRecommendHotel",
        // "classicRecommendRestaurant"
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
        final returnData = {};
        for (final item in data) {
          if (item['typeName'] == 'hotComment') {
            log('hotComment');
            returnData['comments'] =
                (item['hotCommentModule']['hotCommentList'] as List)
                    .map((e) => Comment.fromJson(e))
                    .toList();
          } else if (item['typeName'] == 'tripBestRank') {
            log('tripBestRank');
            returnData['tripbestModule'] = (item['tripBestRankingInfoModule']
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

  @override
  Future<GeoApiLocationModel> convertGeoLocationToAddress({
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse(
        'https://api.geoapify.com/v1/geocode/reverse?lat=$latitude&lon=$longitude&format=json&apiKey=${dotenv.env['GEOCONVERT_API_KEY']!}');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        // return jsonResponse['results'][0]['address_line2'];

        final res = await supabaseClient
            .from('locations')
            .select('id')
            .eq('name', jsonResponse['results'][0]['city'])
            .limit(1)
            .maybeSingle();

        if (res != null) {
          return GeoApiLocationModel(
              address: jsonResponse['results'][0]['address_line2'],
              cityName: jsonResponse['results'][0]['city'],
              latitude: latitude,
              id: res['id'],
              longitude: longitude);
        }

        throw const ServerException('Location not found');
      } else {
        throw ServerException(response.body);
      }
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  @override
  Future<GeoApiLocationModel> convertAddressToGeoLocation({
    required String address,
  }) async {
    String baseUrl = "https://api.geoapify.com/v1/geocode/search";
    String text = address;
    String encodedText = Uri.encodeComponent(text);

    String url =
        "$baseUrl?text=$encodedText&limit=1&filter=countrycode:vn&format=json&apiKey=${dotenv.env['GEOCONVERT_API_KEY']}";
    final convertAddressLongLat = Uri.parse(url);

    try {
      final response = await http.get(convertAddressLongLat);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        log(jsonResponse.toString());
        return GeoApiLocationModel(
            address: jsonResponse['results'][0]['formatted'],
            cityName: jsonResponse['results'][0]['city'],
            latitude: jsonResponse['results'][0]['lat'],
            id: 0,
            longitude: jsonResponse['results'][0]['lon']);
      } else {
        throw ServerException(response.body);
      }
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }
}
