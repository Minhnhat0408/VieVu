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

  Future<GenericLocationInfo> getLocationGeneralInfo({
    required int locationId,
    required String locationName,
    required String userId,
  });

  Future<GeoApiLocationModel> convertGeoLocationToAddress({
    required double latitude,
    required double longitude,
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
  Future<GenericLocationInfo> getLocationGeneralInfo({
    required int locationId,
    required String locationName,
    required String userId,
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
          } else if (item['typeName'] == 'tripBestRank') {
            log('tripBestRank');
            returnData.tripbestModule = (item['tripBestRankingInfoModule']
                    ['rankgingInfoTabList'] as List)
                .map((e) => TripBest.fromJson(e))
                .toList();
          }
        }

        final att = await _getAttractionsWithFilter(
            userId: userId,
            locationId: locationId,
            limit: 8,
            offset: 0,
            sortType: "hot_score",
            topRanked: false);

        returnData.attractions = att;

        final ress = await _getRestaurantsWithFilter(
          userId: userId,
          limit: 8,
          offset: 1,
          locationId: locationId,
        );
        returnData.restaurants = ress;

        final hotel = await _getHotelsWithFilter(
          userId: userId,
          checkInDate: DateTime.now(),
          checkOutDate: DateTime.now().add(const Duration(days: 1)),
          roomQuantity: 1,
          adultCount: 2,
          childCount: 0,
          limit: 8,
          offset: 1,
          locationName: locationName,
        );
        returnData.hotels = hotel;
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

  Future<List<AttractionModel>> _getAttractionsWithFilter({
    required String userId,
    String? categoryId1,
    List<String>? categoryId2,
    required int limit,
    required int offset,
    int? budget,
    int? rating,
    double? lat,
    double? lon,
    int? proximity,
    int? locationId,
    required String sortType,
    required bool topRanked,
  }) async {
    try {
      var query = supabaseClient.rpc('get_attractions', params: {
        'loc_id': locationId,
        'partraveltype_id': categoryId1,
        'traveltype_ids': categoryId2,
        'sorttype': sortType,
        'lon': lon,
        'lat': lat,
        'proximity': proximity,
      });

      if (topRanked) {
        query = query.not('rank_info', 'is', null);
      }
      if (rating != null) {
        if (rating == 2) {
          query = query.gte('avg_rating', 0.0).lte('avg_rating', rating + 0.5);
        }
        query = query
            .gte('avg_rating', rating - 0.5)
            .lte('avg_rating', rating + 0.5);
      }
      if (budget != null) {
        if (budget == 0) {
          query = query.isFilter('price', null);
        } else if (budget == 1) {
          query = query.or('price.is.null, price.lte.200000');
        } else if (budget == 2) {
          query = query.gte('price', 200000).lte('price', 500000);
        } else {
          query = query.gte('price', 500000);
        }
      }

      final response = await query.range(offset, offset + limit);

      final res2 = await supabaseClient
          .from('trips')
          .select('saved_services!inner(link_id)')
          .eq('owner_id', userId)
          .inFilter(
              'saved_services.link_id', response.map((e) => e['id']).toList());
      final linkIds = res2
          .expand(
              (item) => item['saved_services'] ?? []) // Flatten saved_services
          .map((service) => service['link_id']) // Extract link_id
          .toList();
      return (response as List).map((e) {
        return AttractionModel.fromJson(e).copyWith(
          isSaved: linkIds.contains(e['id']),
        );
      }).toList();
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  Future<List<RestaurantModel>> _getRestaurantsWithFilter({
    required String userId,
    int? categoryId1,
    List<int> serviceIds = const [],
    List<int> openTime = const [],
    required int limit,
    required int offset,
    int? minPrice,
    int? maxPrice,
    double? lat,
    double? lon,
    int? locationId,
  }) async {
    final url =
        Uri.parse('https://vn.trip.com/restapi/soa2/18361/foodListSearch');

    final body = {
      "head": {
        "extension": [
          {"name": "locale", "value": "vi-VN"},
          {"name": "platform", "value": "Online"},
          {"name": "currency", "value": "VND"}
        ]
      },
      "districtId": locationId,
      "sortType": "score",
      "pageIndex": offset,
      "pageSize": limit,
      "lat": lat,
      "lon": lon,
      "tag": 0,
      "filterType": 2,
      "serviceTypes": [],
      "filterId": categoryId1,
      "tagIds": null,
      "minPrice": minPrice,
      "maxPrice": maxPrice,
      "opentimeType": openTime,
      "serviceFeaturesIds": serviceIds,
      "fromPage": null
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final data = jsonResponse['results'] as List<dynamic>;

        // Initialize HtmlUnescape
        final unescape = HtmlUnescape();
        final res2 = await supabaseClient
            .from('trips')
            .select('saved_services!inner(link_id)')
            .eq('owner_id', userId)
            .inFilter(
                'saved_services.link_id', data.map((e) => e['poiId']).toList());
        final linkIds = res2
            .expand((item) =>
                item['saved_services'] ?? []) // Flatten saved_services
            .map((service) => service['link_id']) // Extract link_id
            .toList();
        // Decode HTML entities in each restaurant's data
        return data.map((e) {
          // Assuming RestaurantModel has a fromJson method
          final restaurant = RestaurantModel.fromJson(e).copyWith(
            // Decode HTML entities in relevant fields
            // name: unescape.convert(e['name']),
            isSaved: linkIds.contains(e['poiId']),
            userContent: e?['commentInfo'] != null
                ? unescape.convert(e?['commentInfo']?['content'])
                : null,
            // Repeat for other fields as necessary
          );

          return restaurant;
        }).toList();
      } else {
        throw ServerException("Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  Future<List<HotelModel>> _getHotelsWithFilter({
    required String userId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int roomQuantity,
    required int adultCount,
    required int childCount,
    int? star,
    required int limit,
    required int offset,
    int? minPrice,
    int? maxPrice,
    required String locationName,
  }) async {
    final url = Uri.parse('https://vn.trip.com/htls/getHotelList');
    final cityIdUrl = Uri.parse('https://vn.trip.com/htls/getKeyWordSearch');

    final body = {
      "code": 0,
      "codeType": "",
      "keyWord": locationName,
      "searchType": "D",
      "scenicCode": 0,
      "cityCodeOfUser": 0,
      "searchConditions": [
        {"type": "D_PROVINCE", "value": "T"},
        {"type": "SupportNormalSearch", "value": "T"},
        {"type": "DisplayTagIcon", "value": "F"}
      ],
      "head": {
        "platform": "PC",
        "clientId": "1730100685388.e15dmCQTWglp",
        "bu": "ibu",
        "group": "TRIP",
        "couid": "",
        "region": "VN",
        "locale": "vi-VN",
        "timeZone": "7",
        "currency": "VND"
      }
    };

    try {
      final response = await http.post(
        cityIdUrl,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final data = jsonResponse['keyWordSearchResults'] as List<dynamic>;
        final cityId = data[0]?['city']?['geoCode'];
        final filterId = data[0]?['item']?['data'];
        if (cityId == null) {
          throw const ServerException("Failed to fetch cityId");
        }

        String checkIn = DateFormat('yyyyMMdd').format(checkInDate);
        String checkOut = DateFormat('yyyyMMdd').format(checkOutDate);
        final hotelFilterBody = {
          "guideLogin": "T",
          "search": {
            "checkIn": checkIn,
            "checkOut": checkOut,

            // "pageCode": 10320668148,
            "location": {
              "geo": {
                "countryID": 111,
                "provinceID": 0,
                "cityID": cityId,
                "districtID": 0,
                "oversea": true
              }
              // "coordinates": [16.054899, 108.245093]
            },
            "pageIndex": offset,
            "pageSize": limit,
            "needTagMerge": "T",
            "roomQuantity": roomQuantity,
            "orderFieldSelectedByUser": false,
            "hotelId": 0,
            "hotelIds": [],
            "tripWalkDriveSwitch": "T",
            "resultType": "CT"
          },
          "queryTag": "NORMAL",
          "mapType": "GOOGLE",
          "extends": {
            "crossPriceConsistencyLog": "",
            "NewTaxDescForAmountshowtype0": "B",
            "TaxDescForAmountshowtype2": "T",
            "MealTagDependOnMealType": "T",
            "MultiMainHotelPics": "T",
            "enableDynamicRefresh": "T",
            "isFirstDynamicRefresh": "T",
            "ExposeBedInfos": "F",
            "TaxDescRemoveRoomNight": "",
            "priceMaskLoginTip": "",
            "NeedHotelHighLight": "T"
          },
          "head": {
            "platform": "Postman",
            "clientId": "1730100685388.e15dmCQTWglp",
            "bu": "ibu",
            "group": "TRIP",
            "region": "VN",
            "locale": "vi-VN",
            "timeZone": "7",
            "currency": "VND",
            "deviceConfig": "H"
          }
        };
        final search = hotelFilterBody['search'] as Map<String, dynamic>;
        search['filters'] = [];
        if (filterId != null) {
          search['filters'].add({
            "filterId": filterId['filterID'] ?? filterId['filterId'],
            "value": filterId['value'],
            "type": filterId['type'],
            "subType": filterId['subType'],
          });
        }
        search['filters'].add({
          "filterId": "17|1",
          "value": "1",
          "type": "17",
          "subType": "2",
          "sceneType": "17"
        });
        search['filters'].add({
          "filterId": "80|0|1",
          "value": "0",
          "type": "80",
          "subType": "2",
          "sceneType": "80"
        });

        search['filters']
            .add({"filterId": "29|1", "value": "1|$adultCount", "type": "29"});
        for (var i = 0; i < childCount; i++) {
          search['filters'].add({
            "filterId": "29|${i + 2}|4",
            "value": "${i + 2}|4",
            "type": "29"
          });
        }
        search['filters']
            .add({"filterId": "29|2", "value": "2|$childCount", "type": "29"});

        if (star != null) {
          search['filters'].add(
            {
              "filterId": "16|$star", // star
              "value": "$star",
              "type": "16",
              "subType": "2",
              "sceneType": "16"
            },
          );
        }
        if (minPrice != null || maxPrice != null) {
          final min = minPrice ?? 0;
          final max =
              (maxPrice == null || maxPrice == 6300000) ? 6300000 : maxPrice;

          search['filters'].add({
            "filterId": "15|Range",
            "type": "15",
            "subType": "2",
            "priceBarMax": 6300000,
            "value": "$min|$max", // Convert to a string explicitly
          });
        }
        final response2 = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode(hotelFilterBody),
        );

        if (response2.statusCode == 200) {
          final jsonResponse = jsonDecode(utf8.decode(response2.bodyBytes));
          final data = jsonResponse['hotelList'] as List<dynamic>;

          final res2 = await supabaseClient
              .from('trips')
              .select('saved_services!inner(link_id)')
              .eq('owner_id', userId)
              .inFilter('saved_services.link_id',
                  data.map((e) => e['hotelBasicInfo']['hotelId']).toList());
          final linkIds = res2
              .expand((item) =>
                  item['saved_services'] ?? []) // Flatten saved_services
              .map((service) => service['link_id']) // Extract link_id
              .toList();
          return data.map((e) {
            final hotel = HotelModel.fromJson(e).copyWith(
              isSaved: linkIds.contains(e['hotelBasicInfo']['hotelId']),
            );

            return hotel;
          }).toList();
        } else {
          throw ServerException(
              "Failed to fetch data: ${response2.statusCode}");
        }
      } else {
        throw ServerException("Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      log("${e}hotel bug");
      throw ServerException(e.toString());
    }
  }
}
