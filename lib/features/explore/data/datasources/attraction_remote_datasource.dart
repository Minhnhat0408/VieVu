import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/features/explore/data/models/attraction_model.dart';
import 'package:vn_travel_companion/features/explore/data/models/hotel_model.dart';
import 'package:vn_travel_companion/features/explore/data/models/restaurant_model.dart';
import 'package:vn_travel_companion/features/explore/data/models/service_model.dart';
import 'package:html_unescape/html_unescape.dart';

abstract interface class AttractionRemoteDatasource {
  Future<AttractionModel?> getAttraction({
    required int attractionId,
  });

  Future<List<AttractionModel>> getHotAttractions({
    required int limit,
    required int offset,
  });

  Future<List<AttractionModel>> getRecentViewedAttractions({
    required int limit,
  });

  Future upsertRecentViewedAttractions({
    required int attractionId,
    required String userId,
  });

  Future<List<AttractionModel>> getNearbyAttractions({
    required double latitude,
    required double longitude,
    required int limit,
    required int offset,
    required int radius,
  });

  Future<Map<String, List<ServiceModel>>> getAllServicesNearby({
    required double latitude,
    required double longitude,
    int limit = 10,
    int offset = 1,
    required String filterType,
  });

  Future<List<ServiceModel>> getServicesNearAttraction({
    int? attractionId,
    double? latitude,
    double? longitude,
    int limit = 20,
    int offset = 1,
    required int
        serviceType, // 1 for restaurant, 2 for poi,3 for shop, 4 for hotel
    required String filterType, // 43;true 42;true nearbyDistance nearby10KM
  });

  Future<List<AttractionModel>> getRecommendedAttractions({
    required int limit,
    required String userId,
  });

  Future<List<AttractionModel>> getRelatedAttractions({
    required int limit,
    required int attractionId,
  });

  Future<List<AttractionModel>> getAttractionsWithFilter({
    String? categoryId1,
    List<String>? categoryId2,
    required int limit,
    required int offset,
    int? budget, // 1 for low, 2 for medium, 3 for high , 0 for free
    int?
        rating, // 1 for below, 2 for 2 stars, 3 for 3 stars, 4 for 4 stars, 5 for 5 stars
    double? lat,
    double? lon,
    int? proximity,
    int? locationId,
    required String sortType,
    required bool topRanked,
  });

  Future<List<RestaurantModel>> getRestaurantsWithFilter({
    int? categoryId1,
    List<int> serviceIds,
    List<int> openTime,
    required int limit,
    required int offset,
    int? minPrice,
    int? maxPrice,
    double? lat,
    double? lon,
    int? locationId,
  });

  Future<List<HotelModel>> getHotelsWithFilter({
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
  });
}

class AttractionRemoteDatasourceImpl implements AttractionRemoteDatasource {
  final SupabaseClient supabaseClient;

  AttractionRemoteDatasourceImpl(
    this.supabaseClient,
  );

  @override
  Future<AttractionModel?> getAttraction({
    required int attractionId,
  }) async {
    try {
      final response = await supabaseClient
          .from('attractions')
          .select('*, attraction_types(id, type_name)')
          .eq('id', attractionId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return AttractionModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<AttractionModel>> getHotAttractions({
    required int limit,
    required int offset,
  }) async {
    try {
      final response = await supabaseClient
          .from('attractions')
          .select('*, attraction_types(id, type_name)')
          .order('hot_score', ascending: false)
          .range(offset, offset + limit);

      return response.map((e) {
        return AttractionModel.fromJson(e);
      }).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<AttractionModel>> getRecentViewedAttractions({
    required int limit,
  }) async {
    try {
      final response = await supabaseClient
          .from('viewed_history')
          .select('*, attractions(*)')
          .order('created_at', ascending: false)
          .range(0, limit);

      return response
          .map((e) => AttractionModel.fromJson(e['attractions']))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future upsertRecentViewedAttractions({
    required int attractionId,
    required String userId,
  }) async {
    try {
      await supabaseClient.from('viewed_history').upsert({
        'user_id': userId,
        'attraction_id': attractionId,
        'viewed_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<AttractionModel>> getNearbyAttractions({
    required double latitude,
    required double longitude,
    required int limit,
    required int offset,
    required int radius,
  }) async {
    try {
      final response = await supabaseClient.rpc('fetch_nearby_places', params: {
        'lat': latitude,
        'long': longitude,
        'lim': limit,
        'off_set': offset,
        'proximity': radius,
      });
      final List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(response);

      return data.map((e) => AttractionModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ServiceModel>> getServicesNearAttraction({
    int? attractionId,
    double? latitude,
    double? longitude,
    int limit = 20,
    int offset = 1,
    required int serviceType,
    required String filterType,
  }) async {
    final url = Uri.parse(
        'https://vn.trip.com/restapi/soa2/19913/getTripNearbyModuleList');

    final body = {
      "moduleList": [
        {
          "count": limit,
          "index": offset,
          "quickFilterType": filterType,
          "type": serviceType,
          "distance": 100
        }
      ],
      "coordinate": {
        "coordinateType": "GCJ02",
        "latitude": latitude ?? 0,
        "longitude": longitude ?? 0
      },
      "poiId": attractionId,
      "head": {
        "locale": "vi-VN",
        "cver": "3.0",
        "cid": "1730100685388.e15dmCQTWglp",
        "syscode": "999",
        "sid": "",
        "extension": [
          {"name": "locale", "value": "vi-VN"},
          {"name": "platform", "value": "Online"},
          {"name": "currency", "value": "VND"},
          {"name": "aid", "value": ""}
        ]
      }
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json", // Specify the content type
        },
        body: jsonEncode(body), // Convert the body to JSON
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final nearbyModuleList =
            jsonResponse['nearbyModuleList'] as List<dynamic>?;
        if (nearbyModuleList != null &&
            nearbyModuleList.isNotEmpty &&
            nearbyModuleList[0]['totalCount'] > 0) {
          final itemList = nearbyModuleList[0]['itemList'] as List<dynamic>;
          if (serviceType == 1) {
            return itemList.map((item) {
              item['typeId'] = 1;
              return ServiceModel.fromRestaurantJson(
                item as Map<String, dynamic>,
              );
            }).toList();
          } else if (serviceType == 2) {
            return itemList.map((item) {
              item['typeId'] = 2;
              return ServiceModel.fromAttractionJson(
                item as Map<String, dynamic>,
              );
            }).toList();
          } else if (serviceType == 3) {
            return itemList.map((item) {
              item['typeId'] = 3;
              return ServiceModel.fromShopJson(
                item as Map<String, dynamic>,
              );
            }).toList();
          } else {
            return itemList.map((item) {
              item['typeId'] = 4;
              return ServiceModel.fromHotelJson(
                item as Map<String, dynamic>,
              );
            }).toList();
          }
        } else {
          return [];
        }
      } else {
        throw ServerException("Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, List<ServiceModel>>> getAllServicesNearby({
    required double latitude,
    required double longitude,
    int limit = 10,
    int offset = 1,
    required String filterType,
  }) async {
    final url = Uri.parse(
        'https://vn.trip.com/restapi/soa2/19913/getTripNearbyModuleList');
    final Map<String, List<ServiceModel>> services = {
      'restaurants': [],
      'attractions': [],
      'hotels': [],
    };
    try {
      for (var i in [1, 2, 4]) {
        final body = {
          "moduleList": [
            {
              "count": limit,
              "index": offset,
              "quickFilterType": filterType,
              "type": i,
              "distance": 100
            }
          ],
          "coordinate": {
            "coordinateType": "GCJ02",
            "latitude": latitude,
            "longitude": longitude
          },
          "head": {
            "locale": "vi-VN",
            "cver": "3.0",
            "cid": "1730100685388.e15dmCQTWglp",
            "syscode": "999",
            "sid": "",
            "extension": [
              {"name": "locale", "value": "vi-VN"},
              {"name": "platform", "value": "Online"},
              {"name": "currency", "value": "VND"},
              {"name": "aid", "value": ""}
            ]
          }
        };
        final response = await http.post(
          url,
          headers: {
            "Content-Type": "application/json", // Specify the content type
          },
          body: jsonEncode(body), // Convert the body to JSON
        );
        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          final nearbyModuleList =
              jsonResponse['nearbyModuleList'] as List<dynamic>?;
          if (nearbyModuleList != null &&
              nearbyModuleList.isNotEmpty &&
              nearbyModuleList[0]['totalCount'] > 0) {
            final itemList = nearbyModuleList[0]['itemList'] as List<dynamic>;
            if (i == 1) {
              services['restaurants'] = itemList.map((item) {
                item['typeId'] = 1;
                return ServiceModel.fromRestaurantJson(
                  item as Map<String, dynamic>,
                );
              }).toList();
            } else if (i == 2) {
              services['attractions'] = itemList.map((item) {
                item['typeId'] = 2;
                return ServiceModel.fromAttractionJson(
                  item as Map<String, dynamic>,
                );
              }).toList();
            } else {
              services['hotels'] = itemList.map((item) {
                item['typeId'] = 4;

                return ServiceModel.fromHotelJson(
                  item as Map<String, dynamic>,
                );
              }).toList();
            }
          } else {
            return services;
          }
        } else {
          throw ServerException("Failed to fetch data: ${response.statusCode}");
        }
      }

      return services;
    } catch (e) {
      log('${e}service bug');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<AttractionModel>> getRecommendedAttractions({
    required int limit,
    required String userId,
  }) async {
    final Uri url =
        Uri.parse('${dotenv.env['RECOMMENDATION_API_URL']!}/recommendations');

    try {
      final response = await supabaseClient
          .from('user_preferences')
          .select()
          .eq('user_id', userId)
          .single();
      // log(response.toString());
      final body = {
        "user_preferences": {
          "user_id": 1,
          "price": response['budget'],
          "avg_rating": response['avg_rating'],
          "rating_count": response['rating_count'],
          ...response['prefs_df'],
        },
        "attraction_ids": [],
        "top_n": limit,
      };
      final responseRecommendation = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (responseRecommendation.statusCode == 200) {
        final jsonResponse =
            jsonDecode(utf8.decode(responseRecommendation.bodyBytes));
        final data = jsonResponse['recommendations'] as List<dynamic>;

        return data.map((e) {
          return AttractionModel.fromJson(e);
        }).toList();
      } else {
        throw ServerException(
            "Failed to fetch data: ${responseRecommendation.statusCode}");
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<AttractionModel>> getRelatedAttractions({
    required int limit,
    required int attractionId,
  }) async {
    final Uri url = Uri.parse(
        '${dotenv.env['RECOMMENDATION_API_URL']!}/related_attractions');
    try {
      final body = {
        "attraction_id": attractionId,
        "similarity_weight": 0.7,
        "top_n": limit,
      };
      final responseRecommendation = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (responseRecommendation.statusCode == 200) {
        final jsonResponse =
            jsonDecode(utf8.decode(responseRecommendation.bodyBytes));
        final data = jsonResponse['related_attractions'] as List<dynamic>;

        return data.map((e) {
          return AttractionModel.fromJson(e);
        }).toList();
      } else {
        throw ServerException(
            "Failed to fetch data: ${responseRecommendation.statusCode}");
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<AttractionModel>> getAttractionsWithFilter({
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
      log('attraction');
      return (response as List).map((e) {
        return AttractionModel.fromJson(e);
      }).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<RestaurantModel>> getRestaurantsWithFilter({
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

        // Decode HTML entities in each restaurant's data
        return data.map((e) {
          log(e.toString());
          // Assuming RestaurantModel has a fromJson method
          final restaurant = RestaurantModel.fromJson(e).copyWith(
            // Decode HTML entities in relevant fields
            // name: unescape.convert(e['name']),
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

  @override
  Future<List<HotelModel>> getHotelsWithFilter({
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
        log(cityId.toString());
        log(locationName);
        //convert dateTime checkin to string like 20250104
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
          log(filterId.toString() + cityId.toString());
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
          // log(data.toString());
          // Decode HTML entities in each restaurant's data
          return data.map((e) {
            log(e.toString());
            // Assuming RestaurantModel has a fromJson method
            // log(e['hotelBasicInfo']['hotelName']);
            final hotel = HotelModel.fromJson(e);

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
