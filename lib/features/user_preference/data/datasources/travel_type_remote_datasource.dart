import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/features/user_preference/data/models/travel_type_model.dart';

abstract interface class TravelTypeRemoteDatasource {
  Future<List<TravelTypeModel>> getParentTravelTypes();

  Future<List<TravelTypeModel>> getTravelTypesByParentIds({
    required List<String> parentIds,
  });
}

class TravelTypeRemoteDatasourceImpl implements TravelTypeRemoteDatasource {
  final SupabaseClient supabaseClient;

  TravelTypeRemoteDatasourceImpl(
    this.supabaseClient,
  );

  @override
  Future<List<TravelTypeModel>> getParentTravelTypes() async {
    try {
      final response = await supabaseClient
          .from('travel_types')
          .select('id, name, parent_id')
          .isFilter('parent_id', null);

      return response.map((e) => TravelTypeModel.fromJson(e)).toList();
    } catch (e) {
      throw const ServerException('Error getting parent travel types');
    }
  }

  @override
  Future<List<TravelTypeModel>> getTravelTypesByParentIds(
      {required List<String> parentIds}) async {
    try {
      final response = await supabaseClient
          .from('travel_types')
          .select('id, name, parent_id')
          .inFilter('parent_id', parentIds)
          .order('name');

      return response.map((e) => TravelTypeModel.fromJson(e)).toList();
    } catch (e) {
      throw const ServerException('Error getting travel types by parent ids');
    }
  }
}
