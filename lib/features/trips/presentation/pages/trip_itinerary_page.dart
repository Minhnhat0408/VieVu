import 'package:flutter/material.dart';

class TripItineraryPage extends StatefulWidget {
  const TripItineraryPage({super.key});

  @override
  State<TripItineraryPage> createState() => _TripItineraryPageState();
}

class _TripItineraryPageState extends State<TripItineraryPage> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const PageStorageKey('trip-itinerary-page'),
      slivers: [
        SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
        const SliverAppBar(
          leading: null,
          title: Text('Saved Services'),
          floating: true,
          pinned: true,
          automaticallyImplyLeading: false,
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return ListTile(
                title: Text('Service $index'),
              );
            },
            childCount: 20,
          ),
        ),
      ],
    );
  }
}
