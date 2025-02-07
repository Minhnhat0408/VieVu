import 'dart:math';

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  return sqrt(pow(lat2 - lat1, 2) + pow(lon2 - lon1, 2));
}

int calculateDaysBetween(DateTime startDate, DateTime endDate) {
  // Ensure the dates are in the correct order (startDate before endDate)
  if (startDate.isAfter(endDate)) {
    throw ArgumentError("Start date must be before end date.");
  }

  // Calculate the difference in days
  return endDate.difference(startDate).inDays;
}
