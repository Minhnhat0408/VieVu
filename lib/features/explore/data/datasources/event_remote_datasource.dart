import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:vn_travel_companion/features/explore/data/models/event_model.dart';

abstract class EventRemoteDatasource {
  Future<List<EventModel>> getHotEvents();
}

class EventRemoteDatasourceImpl implements EventRemoteDatasource {
  final http.Client client;

  EventRemoteDatasourceImpl(this.client);

  @override
  Future<List<EventModel>> getHotEvents() async {
    final url = Uri.parse(
        'https://api-v2.ticketbox.vn/gin/api/v2/discovery/categories');
    try {
      // Fetch trending events
      final response = await client.get(url);
 
      // log(response.body.toString());
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(
          decodedBody,
        );

        if (data['data']['result']['trendingEvents']['events'] != null) {
          final events =
              data['data']['result']['trendingEvents']['events'] as List;

          // Fetch and enrich event details
          List<EventModel> enrichedEvents = [];
          for (var event in events) {
            final enrichedEvent = await _enrichEventWithDetails(event);
            if (enrichedEvent != null) {
              enrichedEvents.add(enrichedEvent);
            }
     
          }
        
          return enrichedEvents;
        } else {
          throw Exception('Trending events not found');
        }
      } else {
        throw Exception(
            'Failed to load events: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching events: $e');
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

        // Extract the desired fields
        final venue = details['data']['result']['venue'] ?? '';
        final address = details['data']['result']['address'] ?? '';

        return EventModel(
          id: event['id'] ?? '',
          day: event['day'] ?? '',
          price: event['price'] ?? 0,
          isFree: event['isFree'] ?? false,
          orgLogo: event['orgLogoUrl'] ?? '',
          deepLink: event['deeplink'] ?? '',
          image: event['imageUrl'] ?? '',
          name: event['name'] ?? '',
          venue: venue,
          address: address,
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
