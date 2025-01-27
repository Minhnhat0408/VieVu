import 'dart:math';

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  return sqrt(pow(lat2 - lat1, 2) + pow(lon2 - lon1, 2));
}
