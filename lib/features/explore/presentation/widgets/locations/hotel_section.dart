import 'package:flutter/material.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/hotel.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/locations/hotel_big_card.dart';

class HotelSection extends StatelessWidget {
  final List<Hotel> hotels;
  final String locationName;
  const HotelSection({
    super.key,
    required this.hotels,
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
                    'Khách sạn',
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
                'Sự giao hòa giữa nét quyến rũ, tính biểu tượng và vẻ đẹp hiện đại ở $locationName',
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
          height: 350, // Height for the horizontal list
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: hotels.length, // Number of items
            itemBuilder: (context, index) {
              return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0
                        ? 20.0
                        : 4.0, // Extra padding for the first item
                    right: index == hotels.length - 1
                        ? 20.0
                        : 4.0, // Extra padding for the last item
                  ),
                  child: HotelBigCard(hotel: hotels[index]));
            },
          ),
        ),
      ],
    );
  }
}
