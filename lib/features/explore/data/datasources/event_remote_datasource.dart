import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/features/explore/data/models/event_model.dart';

abstract class EventRemoteDatasource {
  Future<List<EventModel>> getHotEvents({
    required String userId,
  });

  Future<EventModel> getEventDetails({
    required int eventId,
  });
}

class EventRemoteDatasourceImpl implements EventRemoteDatasource {
  final http.Client client;
  final SupabaseClient supabaseClient;

  EventRemoteDatasourceImpl({
    required this.client,
    required this.supabaseClient,
  });

  @override
  Future<List<EventModel>> getHotEvents({
    required String userId,
  }) async {
    final url = Uri.parse(
        'https://api-v2.ticketbox.vn/gin/api/v2/discovery/categories');
    try {
      // Fetch trending events
      final response = await client.get(url);

     
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(
          decodedBody,
        );

        if (data['data']['result']['specialEvents']['events'] != null) {
          final events =
              data['data']['result']['specialEvents']['events'] as List;

          // Fetch and enrich event details
          List<EventModel> enrichedEvents = [];
          for (var event in events) {
            final enrichedEvent = await _enrichEventWithDetails(event);
            if (enrichedEvent != null) {
              enrichedEvents.add(enrichedEvent);
            }
          }

          final res2 = await supabaseClient
              .from('trips')
              .select('saved_services!inner(link_id)')
              .eq('owner_id', userId)
              .inFilter('saved_services.link_id',
                  enrichedEvents.map((e) => e.id).toList());
          final linkIds = res2
              .expand((item) =>
                  item['saved_services'] ?? []) // Flatten saved_services
              .map((service) => service['link_id']) // Extract link_id
              .toList();

          // Mark saved events
          final markedEvents = enrichedEvents.map((event) {
            return event.copyWith(isSaved: linkIds.contains(event.id));
          }).toList();

          return markedEvents;
        } else {
          throw Exception('Trending events not found');
        }
      } else {
        throw Exception(
            'Failed to load events: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      log('Error fetching events: $e');
      throw Exception('Error fetching events: $e');
    }
  }

  @override
  Future<EventModel> getEventDetails({
    required int eventId,
  }) async {
    final url =
        Uri.parse('https://api-v2.ticketbox.vn/gin/api/v1/events/$eventId');
    try {
      final response = await client.get(
          url,
        headers: {'x-accept-language': 'vi'},
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(
          decodedBody,
        );

        return EventModel.fromEventDetails(data['data']['result']);
      } else {
          throw Exception(
              'Failed to load event details: ${response.statusCode} ${response.reasonPhrase}');
        }
      } catch (e) {
        log('Error fetching event details: $e');
      throw Exception('Error fetching event details: $e');
    }
  }

  // Helper method to fetch event details and enrich data
  Future<EventModel?> _enrichEventWithDetails(
      Map<String, dynamic> event) async {
    final eventId = event['id'];

    final detailsUrl =
        Uri.parse('https://api-v2.ticketbox.vn/gin/api/v1/events/$eventId');
    try {
      final response = await client.get(
        detailsUrl,
        headers: {'x-accept-language': 'vi'}, // Add language header
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final details = json.decode(
          decodedBody,
        );

        return EventModel.fromEventDetails(details['data']['result']).copyWith(
          deepLink: event['deeplink'],
          // latitude: jsonResponse['results'][0]['lat'],
          // longitude: jsonResponse['results'][0]['lon'],
        );
      } else {
        return null;
      }
    } catch (e) {
      log('Error fetching event details for $eventId: $e');
      return null;
    }
  }
}
