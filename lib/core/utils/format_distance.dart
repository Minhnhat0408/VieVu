String formatDistance(double distanceInKm) {
  if (distanceInKm >= 1000) {
    // Format large distances with a thousands separator
    return '${(distanceInKm / 1000).toStringAsFixed(1)}k km';
  } else {
    // Format small distances without decimals
    return '${distanceInKm.toStringAsFixed(1)} km';
  }
}
