import 'package:flutter/material.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/tripbest.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/locations/tripbest_card.dart';

class TripbestSection extends StatelessWidget {
  final List<TripBest> tripbests;
  const TripbestSection({
    super.key,
    required this.tripbests,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xếp hạng tốt nhất',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Trải nghiệm tốt nhất được đánh giá cao',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220, // Height for the horizontal list
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tripbests.length, // Number of items
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  left:
                      index == 0 ? 20 : 4.0, // Extra padding for the first item
                  right:
                      index == 9 ? 20 : 4.0, // Extra padding for the last item
                ),
                child: TripbestCard(
                  tripBest: tripbests[index],
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
