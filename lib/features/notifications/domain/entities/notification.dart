import 'package:vievu/features/auth/domain/entities/user.dart';
import 'package:vievu/features/trips/domain/entities/trip.dart';

class Notification {
  final int id;
  final String content;
  final User? user;
  final Trip? trip;
  final String type;
  final DateTime createdAt;
  bool isRead;
  bool? isAccepted;

  Notification({
    required this.id,
    required this.content,
    this.user,
    this.trip,
    required this.type,
    required this.createdAt,
    required this.isRead,
    this.isAccepted,
  });
}
