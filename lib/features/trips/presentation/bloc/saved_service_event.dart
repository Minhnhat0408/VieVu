part of 'saved_service_bloc.dart';

@immutable
sealed class SavedServiceEvent {}

class InsertSavedService extends SavedServiceEvent {
  final String tripId;
  final String? externalLink;
  final int linkId;
  final String cover;
  final String name;
  final String locationName;
  final List<String>? tagInfoList;
  final double rating;
  final int ratingCount;
  final int? hotelStar;
  final DateTime? eventDate;
  final int typeId;
  final double latitude;
  final double longitude;

  InsertSavedService({
    required this.tripId,
    this.externalLink,
    this.eventDate,
    required this.linkId,
    required this.cover,
    required this.name,
    required this.locationName,
    this.tagInfoList,
    required this.rating,
    required this.ratingCount,
    this.hotelStar,
    required this.typeId,
    required this.latitude,
    required this.longitude,
  });
}

class DeleteSavedService extends SavedServiceEvent {
  final int linkId;
  final String tripId;

  DeleteSavedService({required this.linkId, required this.tripId});
}
