import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/features/trips/data/models/saved_service_model.dart';

abstract interface class SavedServiceRemoteDatasource {
  Future insertSavedService({
    required String tripId,
    required SavedServiceModel service,
  });

  Future deleteSavedTrips({
    required int serviceId,
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
    required SavedServiceModel service,
  }) async {
    try {
      await supabaseClient.from('saved_services').insert({
        'trip_id': tripId,
        'external_link': service.externalLink,
        'cover': service.cover,
        'name': service.name,
        'location_name': service.locationName,
        'tag_info_list': service.tagInforList,
        'avg_rating': service.rating,
        'rating_count': service.ratingCount,
        'hotel_star': service.hotelStar,
        'type_id': service.typeId,
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future deleteSavedTrips({
    required int serviceId,
  }) async {
    try {
      await supabaseClient.from('saved_services').delete().eq('id', serviceId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
