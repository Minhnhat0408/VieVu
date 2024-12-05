import 'package:vn_travel_companion/core/constants/travel_type_pref_map.dart';
import 'package:vn_travel_companion/features/user_preference/domain/entities/travel_type.dart';

Map<String, double> generatePref({
  Map<String, double> initialPref = travelPrefDf,
  required List<TravelType> travelTypes,
  required double point,
}) {
  // Create a modifiable copy of the initialPref
  final modifiablePref = Map<String, double>.from(initialPref);

  for (var type in travelTypes) {
    modifiablePref[type.name] = point;
  }
  return modifiablePref;
}
