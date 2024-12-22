import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/features/explore/data/models/attraction_model.dart';
import 'package:vn_travel_companion/features/explore/data/models/service_model.dart';

abstract interface class AttractionRemoteDatasource {
  Future<AttractionModel?> getAttraction({
    required int attractionId,
  });

  Future<List<AttractionModel>> getHotAttractions({
    required int limit,
    required int offset,
  });

  // Future<List<AttractionModel>> getAttractionsByCategory({
  //   required String category,
  //   required int limit,
  //   required int offset,
  // });

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

  Future<List<ServiceModel>> getServicesNearAttraction({
    required int attractionId,
    int limit = 20,
    int offset = 1,
    required int
        serviceType, // 1 for restaurant, 2 for poi,3 for shop, 4 for hotel
    required String filterType, // 43;true 42;true nearbyDistance nearby10KM
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
    required int attractionId,
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
        if (nearbyModuleList != null && nearbyModuleList.isNotEmpty) {
          final itemList = nearbyModuleList[0]['itemList'] as List<dynamic>;
          if (serviceType == 1) {
            return itemList
                .map((item) => ServiceModel.fromRestaurantJson(
                    item as Map<String, dynamic>))
                .toList();
          } else if (serviceType == 2) {
            return itemList
                .map((item) => ServiceModel.fromAttractionJson(
                    item as Map<String, dynamic>))
                .toList();
          } else if (serviceType == 3) {
            return itemList
                .map((item) =>
                    ServiceModel.fromShopJson(item as Map<String, dynamic>))
                .toList();
          } else {
            return itemList
                .map((item) =>
                    ServiceModel.fromHotelJson(item as Map<String, dynamic>))
                .toList();
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
}
