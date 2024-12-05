
import 'package:vn_travel_companion/features/user_preference/domain/entities/preference.dart';

class PreferenceModel extends Preference {
  PreferenceModel(
      {required super.budget,
      required super.avgRating,
      required super.ratingCount,
      required super.prefsDF});

  factory PreferenceModel.fromJson(Map<String, dynamic> json) {
    return PreferenceModel(
      budget: (json['budget'] ?? 0.0).toDouble(),
      avgRating: (json['avg_rating'] ?? 0.0).toDouble(),
      ratingCount: json['rating_count'] ?? 0,
      prefsDF: (json['prefs_df'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'budget': budget,
      'avg_rating': avgRating,
      'rating_count': ratingCount,
      'prefs_df': prefsDF,
    };
  }

  PreferenceModel copyWith({
    double? budget,
    double? avgRating,
    int? ratingCount,
    Map<String, double>? prefsDF,
  }) {
    return PreferenceModel(
      budget: budget ?? this.budget,
      avgRating: avgRating ?? this.avgRating,
      ratingCount: ratingCount ?? this.ratingCount,
      prefsDF: prefsDF ?? this.prefsDF,
    );
  }
}
