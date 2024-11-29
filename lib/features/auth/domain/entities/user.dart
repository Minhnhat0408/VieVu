// ignore_for_file: public_member_api_docs, sort_constructors_first
class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? gender;
  final String? phoneNumber;
  final String? avatarUrl;
  final String? dob;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    this.dob,
    this.gender,
    this.phoneNumber,
  });
}
