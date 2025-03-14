import 'package:flutter/material.dart';

class TripReview {
  final int rating;

  TripReview(this.rating);
}

class RatingSummary extends StatelessWidget {
  final List<TripReview> tripReviews;

  const RatingSummary({super.key, required this.tripReviews});

  @override
  Widget build(BuildContext context) {
    // Calculate average rating
    double averageRating = tripReviews.isNotEmpty
        ? tripReviews.map((e) => e.rating).reduce((a, b) => a + b) /
            tripReviews.length
        : 0.0;

    // Count rating occurrences (from 5-star to 1-star)
    Map<int, int> ratingCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var review in tripReviews) {
      ratingCounts[review.rating] = ratingCounts[review.rating]! + 1;
    }

    int maxCount = ratingCounts.values.isNotEmpty
        ? ratingCounts.values.reduce((a, b) => a > b ? a : b)
        : 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Average Rating & Total Reviews
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(
                  averageRating.toStringAsFixed(1), // Display 1 decimal place
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 40,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${tripReviews.length} đánh giá',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(width: 20), // Space between columns
        // Right Column: Star Distribution
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(5, (index) {
              int star = 5 - index;
              double percentage =
                  maxCount > 0 ? ratingCounts[star]! / maxCount : 0.0;
              return Row(
                children: [
                  Text("$star",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 5),
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 5),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: Colors.grey[300],
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.amber),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text("${ratingCounts[star]}",
                      style: const TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

// Example Usage
void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text("Rating Summary")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RatingSummary(
          tripReviews: [
            TripReview(5),
            TripReview(4),
            TripReview(5),
            TripReview(3),
            TripReview(4),
            TripReview(2),
            TripReview(5),
            TripReview(1),
            TripReview(3),
          ],
        ),
      ),
    ),
  ));
}
