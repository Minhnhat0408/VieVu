import 'package:vn_travel_companion/features/user_preference/domain/entities/travel_type.dart';

class TravelTypeModel extends TravelType {
  TravelTypeModel({required super.id, required super.name, super.parentId});

  factory TravelTypeModel.fromJson(Map<String, dynamic> json) {
    return TravelTypeModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      parentId: json['parent_id'],
    );
  }

  TravelTypeModel copyWith({
    String? id,
    String? name,
    String? parentId,
  }) {
    return TravelTypeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
    );
  }
}
