import 'package:flutter/material.dart';
import 'package:vievu/features/explore/domain/entities/location.dart';
import 'package:vievu/features/explore/presentation/pages/location_detail_page.dart';

class SubLocationSection extends StatelessWidget {
  final List<Location> locations;
  final String locationName;
  const SubLocationSection({
    super.key,
    required this.locations,
    required this.locationName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(top: 30, bottom: 20, left: 20, right: 20),
          child: Text(
            'Các điểm đến phổ biến thuộc $locationName',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 10.0),
            child: Wrap(
              spacing: 8.0, // Horizontal spacing between items
              runSpacing: 8.0, // Vertical spacing between lines
              children: List.generate(
                locations.length,
                (index) => InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => LocationDetailPage(
                            locationId: locations[index].id,
                            locationName: locations[index].name)));
                  },
                  child: Container(
                    width: 115,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: Center(
                      child: Text(
                        locations[index].name,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
