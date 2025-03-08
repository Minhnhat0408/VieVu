// ignore_for_file: public_member_api_docs, sort_constructors_first
class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? gender; //TODO: Change to ENUM
  final String? phoneNumber;
  final String? bio;
  final String? avatarUrl;
  final String? city;
  final int tripCount;
  final int ratingCount;
  final double avgRating;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.tripCount,
    required this.ratingCount,
    required this.avgRating,
    this.avatarUrl,
    this.bio,
    this.city,
    this.gender,
    this.phoneNumber,
  });
}
