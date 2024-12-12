import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/features/explore/data/models/attraction_model.dart';

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
          .select('*')
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
}
