import 'dart:developer';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
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
    required String type,
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
      }).select();
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
      var query = supabaseClient.from('trips').select();

      if (status != null) {
        query = query.eq('status', status);
      }

      if (startDate != null) {
        query = query.gte('start_date', startDate);
      }

      if (endDate != null) {
        query = query.lte('end_date', endDate);
      }

      if (transports != null) {
        query = query.contains('transports', transports);
      }

      if (locationIds != null) {
        query = query.contains('location_ids', locationIds);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit);

      return response.map((e) => TripModel.fromJson(e)).toList();
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
            tripId,
            file,
          );

      return supabaseClient.storage.from('trip_cover_images').getPublicUrl(
            tripId,
          );
    } on StorageException catch (e) {
      log(e.toString());
      throw ServerException(e.message);
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
    required String type,
  }) async {
    try {
      var query = supabaseClient
          .from('trips')
          .select(
              '*, trip_locations(locations(name, id), is_starting_point), service_count:saved_services(count), saved_services(name,external_link, link_id)')
          .eq('owner_id', userId);

      if (status != null) {
        query = query.eq('status', status);
      }

      if (isPublished != null) {
        query = query.eq('is_published', isPublished);
      }

      final response = await query.order('created_at', ascending: false);
      return response.map((e) {
        final tripItem = e;
        tripItem['service_count'] = e['service_count'][0]['count'];
        final locations = e['trip_locations'] as List;
        final services = e['saved_services'] as List;
        tripItem['locations'] = <String>[];
        if (type == "location" && locations.isNotEmpty) {
          // check if the trip contains the location id
          final locationIndex = locations.indexWhere((element) {
            return element['locations']['id'] == id;
          });

          if (locationIndex != -1) {
            tripItem['is_saved'] = true;
          }
          tripItem['locations'] = locations
              .map<String>(
                (e) => e['locations']['name'],
              )
              .toList();
        } else if (type == "service" && services.isNotEmpty) {
          final serviceIndex = services.indexWhere((element) {
            return element['link_id'] == id;
          });

          if (serviceIndex != -1) {
            tripItem['is_saved'] = true;
          }
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
              '*, trip_locations(locations(name), is_starting_point), saved_services(count)')
          .eq('owner_id', userId);

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
        tripItem['service_count'] = e['saved_services'][0]['count'];
        final locations = e['trip_locations'] as List;

        tripItem['locations'] = <String>[];
        if (locations.isNotEmpty) {
          final startingPointIndex = locations.indexWhere((element) {
            return element['is_starting_point'] == true;
          });
          if (startingPointIndex != -1) {
            final startingPoint = locations[startingPointIndex];
            locations.removeAt(startingPointIndex);
            locations.insert(0, startingPoint);
          }

          tripItem['locations'] = locations
              .map<String>(
                (e) => e['locations']['name'],
              )
              .toList();
        }

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
          .select('*, trip_locations(locations(name), is_starting_point)')
          .eq('id', tripId)
          .single();

      final tripItem = res;
      final locations = res['trip_locations'] as List;

      tripItem['locations'] = <String>[];
      if (locations.isNotEmpty) {
        final startingPointIndex = locations.indexWhere((element) {
          return element['is_starting_point'] == true;
        });
        if (startingPointIndex != -1) {
          final startingPoint = locations[startingPointIndex];
          locations.removeAt(startingPointIndex);
          locations.insert(0, startingPoint);
        }

        tripItem['locations'] = locations
            .map<String>(
              (e) => e['locations']['name'],
            )
            .toList();
      }

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

      if (isPublished != null) {
        //check if trip have all the required fields
        final res = await supabaseClient
            .from('trips')
            .select('*, trip_locations(count)')
            .eq('id', tripId)
            .maybeSingle(); // Prevents crash if no row is found

        if (res == null) {
          throw const ServerException('Không có quyền cập nhật chuyến đi');
        }
        if (res['trip_locations'][0]['count'] == 0) {
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
            .select('*, trip_locations(locations(name), is_starting_point)')
            .maybeSingle(); // Prevents crash if no row is found

        if (res == null) {
          throw const ServerException('Không có quyền cập nhật chuyến đi');
        }

        final tripItem = res;
        final locations = res['trip_locations'] as List;
        tripItem['locations'] = <String>[];
        if (locations.isNotEmpty) {
          final startingPointIndex = locations.indexWhere((element) {
            return element['is_starting_point'] == true;
          });
          if (startingPointIndex != -1) {
            final startingPoint = locations[startingPointIndex];
            locations.removeAt(startingPointIndex);
            locations.insert(0, startingPoint);
          }

          tripItem['locations'] = locations
              .map<String>(
                (e) => e['locations']['name'],
              )
              .toList();
        }

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
  }
  if (transports != null) {
    updateObject['transports'] = transports;
  }

  return updateObject;
}
