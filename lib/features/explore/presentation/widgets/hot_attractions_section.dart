
import 'package:flutter/material.dart';

class HotAttractionsSection extends StatefulWidget {
  const HotAttractionsSection({super.key});

  @override
  State<HotAttractionsSection> createState() => _HotAttractionsSectionState();
}

class _HotAttractionsSectionState extends State<HotAttractionsSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Trải nghiệm hàng đầu ở Việt Nam',
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 400, // Height for the horizontal list
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 10, // Number of items
            itemBuilder: (context, index) {
              return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0
                        ? 20.0
                        : 4.0, // Extra padding for the first item
                    right: index == 9
                        ? 20.0
                        : 4.0, // Extra padding for the last item
                  ),
                  child: Card(
                    elevation: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      clipBehavior: Clip.antiAlias,
                      width: 220, // Fixed width for each card
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stack to overlay the icon button on the image
                          Stack(
                            children: [
                              SizedBox(
                                height: 220,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                  child: Image.asset(
                                    'assets/images/intro1.jpg',
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top:
                                    8, // Adjust this value to move the button down
                                right:
                                    8, // Adjust this value to move the button right
                                child: IconButton(
                                  onPressed: () {
                                    // Handle heart icon press here
                                  },
                                  style: IconButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                  ),
                                  icon: const Icon(
                                    Icons.favorite_border, // Heart icon
                                    // Icon color
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text(
                                  'Attraction $index',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  'Attraction $index',
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                                Text(
                                  'Attraction $index',
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ));
            },
          ),
        ),
      ],
    );
  }
}
