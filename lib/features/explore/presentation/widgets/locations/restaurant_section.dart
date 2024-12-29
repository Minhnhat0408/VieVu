import 'package:flutter/material.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/restaurant.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/locations/restaurant_big_card.dart';

class RestaurantSection extends StatelessWidget {
  final List<Restaurant> restaurants;
  final String locationName;
  const RestaurantSection({
    super.key,
    required this.restaurants,
    required this.locationName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nhà hàng',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/attractions');
                    },
                    child: Text(
                      'Xem tất cả',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Nhà hàng, quán ăn, quán cà phê và quán bar xuất sắc tại $locationName',
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
          height: 400, // Height for the horizontal list
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: restaurants.length, // Number of items
            itemBuilder: (context, index) {
              return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0
                        ? 20.0
                        : 4.0, // Extra padding for the first item
                    right: index == restaurants.length - 1
                        ? 20.0
                        : 4.0, // Extra padding for the last item
                  ),
                  child: RestaurantBigCard(restaurant: restaurants[index]));
            },
          ),
        ),
      ],
    );
  }
}
