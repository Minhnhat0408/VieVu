import 'dart:developer';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/features/trips/data/models/trip_member_model.dart';
import 'package:vn_travel_companion/features/trips/data/models/trip_model.dart';

abstract interface class TripRemoteDatasource {
  Future<TripModel> insertTrip({
    required String name,
    required String userId,
  });
  Future<List<TripModel>> getCurrentUserTrips(
      {required String userId,
      String? status,
      bool? isPublished,
      required int limit,
      required int offset});

  Future<List<TripModel>> getCurrentUserTripsForSave({
    required String userId,
    String? status,
    bool? isPublished,
    required int id,
  });

  Future<List<TripModel>> getTrips({
    required int limit,
    required int offset,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? transports,
    List<String>? locationIds,
  });

  Future<TripModel> getTripDetails({
    required String tripId,
  });

  Future<String> uploadTripCover({
    required String tripId,
    required File file,
  });

  Future<TripModel> updateTrip({
    required String tripId,
    String? description,
    String? cover,
    String? name,
    DateTime? startDate,
    required String updatedAt,
    DateTime? endDate,
    int? maxMember,
    String? status,
    bool? isPublished,
    List<String>? transports,
  });

  Future deleteTrip({
    required String tripId,
  });
}

class TripRemoteDatasourceImpl implements TripRemoteDatasource {
  final SupabaseClient supabaseClient;

  TripRemoteDatasourceImpl(
    this.supabaseClient,
  );

  @override
  Future<TripModel> insertTrip({
    required String name,
    required String userId,
  }) async {
    try {
      final res = await supabaseClient.from('trips').insert({
        'name': name,
        'owner_id': userId,
        'status': 'planning',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).select("*, profiles(*)");
      if (res.isEmpty) {
        throw const ServerException('Failed to insert trip');
      }
      log(res.first.toString());

      return TripModel.fromJson(res.first);
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<TripModel>> getTrips({
    required int limit,
    required int offset,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? transports,
    List<String>? locationIds,
  }) async {
    try {
      var query = supabaseClient
          .from('trips')
          .select("*, saved_services(location_name), profiles(*)")
          .eq('is_published', true);

      if (status != null) {
        query = query.eq('status', status);
      }

      if (startDate != null) {
        query = query.gte('start_date', startDate);
      }

      if (endDate != null) {
        query = query.lte('end_date', endDate);
      }
      log(transports.toString());
      if (transports != null) {
        query = query.overlaps('transports', transports);
      }

      if (locationIds != null) {
        query = query.contains('location_ids', locationIds);
      }

      final response = await query
          .order('published_time', ascending: false)
          .range(offset, offset + limit);

      return response.map((e) {
        final tripItem = e;
        tripItem['service_count'] = e['saved_services'].length;
        tripItem['locations'] = <String>[];
        final locations = (e['saved_services'] as List)
            .map((e) => e['location_name'] as String);

        tripItem['locations'] = locations.toSet().toList();

        return TripModel.fromJson(tripItem);
      }).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadTripCover({
    required File file,
    required String tripId,
  }) async {
    try {
      await supabaseClient.storage.from('trip_cover_images').upload(
            "$tripId.jpg",
            file,
          );

      return supabaseClient.storage.from('trip_cover_images').getPublicUrl(
            "$tripId.jpg",
          );
    } on StorageException catch (e) {
      log(e.toString());
      if (e.message == "The resource already exists") {
        await supabaseClient.storage.from('trip_cover_images').update(
              "$tripId.jpg",
              file,
            );

        log('updated');
        return supabaseClient.storage.from('trip_cover_images').getPublicUrl(
              "$tripId.jpg",
            );
      } else {
        throw ServerException(e.toString());
      }
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<TripModel>> getCurrentUserTripsForSave({
    required String userId,
    String? status,
    bool? isPublished,
    required int id,
  }) async {
    try {
      var query = supabaseClient
          .from('trips')
          .select(
              '*, trip_participants!inner(user_id), saved_services(name,external_link, link_id, location_name)')
          .eq('trip_participants.user_id', userId);

      if (status != null) {
        query = query.eq('status', status);
      }

      if (isPublished != null) {
        query = query.eq('is_published', isPublished);
      }

      final response = await query.order('updated_at', ascending: false);
      return response.map((e) {
        final tripItem = e;
        final services = e['saved_services'] as List;

        tripItem['service_count'] = e['saved_services'].length;
        tripItem['locations'] = <String>[];
        final locations = services.map((e) => e['location_name'] as String);

        tripItem['locations'] = locations.toSet().toList();
        final serviceIndex = services.indexWhere((element) {
          return element['link_id'] == id;
        });

        if (serviceIndex != -1) {
          tripItem['is_saved'] = true;
        }

        return TripModel.fromJson(tripItem);
      }).toList();
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<TripModel>> getCurrentUserTrips(
      {required String userId,
      String? status,
      bool? isPublished,
      required int limit,
      required int offset}) async {
    try {
      log('hellooo');
      var query = supabaseClient
          .from('trips')
          .select(
              '*, trip_participants!inner(user_id), saved_services(location_name)')
          .eq('trip_participants.user_id', userId);
      // .eq('saved_services.type_id', 2);

      if (status != null) {
        query = query.eq('status', status);
      }

      if (isPublished != null) {
        query = query.eq('is_published', isPublished);
      }

      final response = await query
          .order('updated_at', ascending: false)
          .range(offset, offset + limit);

      return response.map((e) {
        final tripItem = e;
        tripItem['service_count'] = e['saved_services'].length;

        tripItem['locations'] = <String>[];
        final locations = (e['saved_services'] as List)
            .map((e) => e['location_name'] as String);

        tripItem['locations'] = locations.toSet().toList();

        return TripModel.fromJson(tripItem);
      }).toList();
    } catch (e) {
      log(e.toString());

      throw ServerException(e.toString());
    }
  }

  @override
  Future<TripModel> getTripDetails({
    required String tripId,
  }) async {
    try {
      final res = await supabaseClient
          .from('trips')
          .select('*,  saved_services(location_name)')
          .eq('id', tripId)
          .single();

      final tripItem = res;
      tripItem['service_count'] = res['saved_services'].length;
      tripItem['locations'] = <String>[];
      final locations = (res['saved_services'] as List)
          .map((e) => e['location_name'] as String);

      tripItem['locations'] = locations.toSet().toList();

      return TripModel.fromJson(tripItem);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TripModel> updateTrip({
    required String tripId,
    String? description,
    String? cover,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    required String updatedAt,
    int? maxMember,
    String? status,
    bool? isPublished,
    List<String>? transports,
  }) async {
    try {
      // check if the user is the owner of the trip

      final updateData = _buildUpdateObject(
        description: description,
        cover: cover,
        startDate: startDate,
        name: name,
        endDate: endDate,
        maxMember: maxMember,
        status: status,
        isPublished: isPublished,
        transports: transports,
      );

      if (startDate != null && endDate != null) {
        await supabaseClient
            .from('trip_itineraries')
            .delete()
            .gt('time', endDate.toIso8601String())
            .lt('time', startDate.toIso8601String());
      }

      if (isPublished != null) {
        //check if trip have all the required fields
        final res = await supabaseClient
            .from('trips')
            .select('*, saved_services(count)')
            .eq('id', tripId)
            .maybeSingle(); // Prevents crash if no row is found

        if (res == null) {
          throw const ServerException('Không có quyền cập nhật chuyến đi');
        }
        if (res['saved_services'][0]['count'] == 0) {
          throw const ServerException(
              'Vui lòng thêm địa điểm cho chuyến đi trước khi công khai');
        }
        if (res['cover'] == null) {
          throw const ServerException(
              'Vui lòng thêm ảnh bìa cho chuyến đi trước  khi công khai');
        }

        if (res['description'] == null) {
          throw const ServerException(
              'Vui lòng thêm mô tả cho chuyến đi trước  khi công khai');
        }

        if (res['start_date'] == null || res['end_date'] == null) {
          throw const ServerException(
              'Vui lòng thêm thời gian cho chuyến đi trước  khi công khai');
        }

        if (res['max_member'] == null) {
          throw const ServerException(
              'Vui lòng thêm số lượng thành viên tối đa cho chuyến đi trước khi công khai');
        }

        if (res['transports'] == null) {
          throw const ServerException(
              'Vui lòng thêm phương tiện di chuyển cho chuyến đi trước  khi công khai');
        }
      }

      if (updateData.isNotEmpty) {
        // Check if there's anything to update
        updateData['updated_at'] = updatedAt;
        final res = await supabaseClient
            .from('trips')
            .update(updateData)
            .eq('id', tripId)
            .select('*, saved_services(location_name)')
            .maybeSingle(); // Prevents crash if no row is found

        if (res == null) {
          throw const ServerException('Không có quyền cập nhật chuyến đi');
        }

        final tripItem = res;
        tripItem['service_count'] = res['saved_services'].length;
        tripItem['locations'] = <String>[];
        final locations = (res['saved_services'] as List)
            .map((e) => e['location_name'] as String);

        tripItem['locations'] = locations.toSet().toList();

        return TripModel.fromJson(tripItem);
      } else {
        throw const ServerException('Nothing to update');
      }
    } catch (e) {
      log(e.toString());

      throw ServerException(e.toString());
    }
  }

  @override
  Future deleteTrip({
    required String tripId,
  }) async {
    try {
      await supabaseClient.from('trips').delete().eq('id', tripId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}

Map<String, dynamic> _buildUpdateObject({
  String? description,
  String? cover,
  String? name,
  DateTime? startDate,
  DateTime? endDate,
  int? maxMember,
  String? status,
  bool? isPublished,
  List<String>? transports,
}) {
  Map<String, dynamic> updateObject = {};

  if (description != null) {
    updateObject['description'] = description;
  }
  if (cover != null) {
    updateObject['cover'] = cover;
  }

  if (name != null) {
    updateObject['name'] = name;
  }
  if (startDate != null) {
    updateObject['start_date'] =
        startDate.toIso8601String(); // Important: Convert DateTime to String
  }
  if (endDate != null) {
    updateObject['end_date'] =
        endDate.toIso8601String(); // Important: Convert DateTime to String
  }
  if (maxMember != null) {
    updateObject['max_member'] = maxMember;
  }
  if (status != null) {
    updateObject['status'] = status;
  }
  if (isPublished != null) {
    updateObject['is_published'] = isPublished;
    if (isPublished) {
      updateObject['published_time'] = DateTime.now().toIso8601String();
    }
  }
  if (transports != null) {
    updateObject['transports'] = transports;
  }

  return updateObject;
}
