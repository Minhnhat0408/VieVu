class Preference {
  final double budget;
  final double avgRating;
  final int ratingCount;
  final Map<String, double> prefsDF;

  Preference({
    required this.budget,
    required this.avgRating,
    required this.ratingCount,
    required this.prefsDF,
  });
}
