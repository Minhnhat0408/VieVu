import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/features/trips/data/models/saved_service_model.dart';

abstract interface class SavedServiceRemoteDatasource {
  Future insertSavedService({
    required String tripId,
    String? externalLink,
    required int linkId,
    required String cover,
    required String name,
    required String locationName,
    List<String>? tagInfoList,
    required double rating,
    required int ratingCount,
    int? hotelStar,
    required int typeId,
    required double latitude,
    required double longitude,
  });

  Future deleteSavedTrips({required int linkId, required String tripId});

  Future getSavedServices({
    required String tripId,
    int? typeId,
  });
}

class SavedServiceRemoteDatasourceImpl implements SavedServiceRemoteDatasource {
  final SupabaseClient supabaseClient;

  SavedServiceRemoteDatasourceImpl(
    this.supabaseClient,
  );

  @override
  Future insertSavedService({
    required String tripId,
    String? externalLink,
    required int linkId,
    required String cover,
    required String name,
    required String locationName,
    List<String>? tagInfoList,
    required double rating,
    required int ratingCount,
    int? hotelStar,
    required int typeId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await supabaseClient.from('saved_services').insert({
        'trip_id': tripId,
        'external_link': externalLink,
        'cover': cover,
        'name': name,
        'location_name': locationName,
        'tag_info_list': tagInfoList,
        'avg_rating': rating,
        'link_id': linkId,
        'rating_count': ratingCount,
        'hotel_star': hotelStar,
        'type_id': typeId,
        'latitude': latitude,
        'longitude': longitude,
      });
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  @override
  Future deleteSavedTrips({required int linkId, required String tripId}) async {
    try {
      final query = supabaseClient
          .from('saved_services')
          .delete()
          .eq('link_id', linkId)
          .eq('trip_id', tripId);

      await query;
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  @override
  Future getSavedServices({
    required String tripId,
    int? typeId,
  }) async {
    try {
      var query = supabaseClient
          .from('saved_services')
          .select('*')
          .eq('trip_id', tripId);

      if (typeId != null) {
        query = query.eq('type_id', typeId);
      }

      final response = await query.order('created_at', ascending: false);

      return response.map((e) => SavedServiceModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
