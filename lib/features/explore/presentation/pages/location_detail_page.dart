import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/location.dart';
import 'package:vn_travel_companion/features/explore/presentation/bloc/location/location_bloc.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/location_info_cubit.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/locations/attraction_section.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/locations/comment_section.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/locations/hotel_section.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/locations/restaurant_section.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/locations/tripbest_section.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/slider_pagination.dart';
import 'package:vn_travel_companion/init_dependencies.dart';

class LocationDetailPage extends StatelessWidget {
  final int locationId;
  final String locationName;
  const LocationDetailPage(
      {super.key, required this.locationId, required this.locationName});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => serviceLocator<LocationBloc>(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<LocationInfoCubit>(),
        ),
      ],
      child: Scaffold(
        body: LocationDetailView(
          locationId: locationId,
          locationName: locationName,
        ),
      ),
    );
  }
}

class LocationDetailView extends StatefulWidget {
  final int locationId;
  final String locationName;

  const LocationDetailView(
      {super.key, required this.locationId, required this.locationName});

  @override
  State<LocationDetailView> createState() => LocationDetailViewState();
}

class LocationDetailViewState extends State<LocationDetailView> {
  @override
  void initState() {
    super.initState();

    context
        .read<LocationBloc>()
        .add(GetLocation(locationId: widget.locationId));
    context.read<LocationInfoCubit>().fetchLocationInfo(widget.locationId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.locationName),
        scrolledUnderElevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Scroll slightly down to make the bottom visible
            },
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
        ],
      ),
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: true,
            leading: null,
            automaticallyImplyLeading: false,
            snap: true,
            scrolledUnderElevation: 0,
            flexibleSpace: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
                child: Row(
                  children: List.generate(
                    10, // Number of buttons
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: OutlinedButton(
                        onPressed: () {
                          // Add behavior for buttons if needed
                        },
                        child: Text('Button ${index + 1}'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
        body: BlocConsumer<LocationBloc, LocationState>(
          listener: (context, state) {
            if (state is LocationFailure) {
              // Show error message
              showSnackbar(context, state.message, 'error');
            }
          },
          builder: (context, state) {
            if (state is LocationLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state is LocationDetailsLoadedSuccess) {
              final Location location = state.location;
              final imgList = [...location.images, location.cover];

              return BlocConsumer<LocationInfoCubit, LocationInfoState>(
                listener: (context, state2) {
                  // Listener if needed
                },
                builder: (context, state2) {
                  if (state2 is LocationInfoLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (state2 is LocationInfoFailure) {
                    return const Center(
                      child: Text('Không có dữ liệu'),
                    );
                  }
                  final locationInfo =
                      (state2 as LocationInfoLoaded).locationInfo;
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            SliderPagination(imgList: imgList),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 80),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Text(
                                  location.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 32),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondaryContainer,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      width: 40,
                                      height: 40,
                                      alignment: Alignment.center,
                                      child: const FaIcon(
                                          FontAwesomeIcons.locationDot,
                                          size: 18),
                                    ),
                                    const SizedBox(width: 16),
                                    Flexible(
                                      child: Text(
                                        location.address,
                                        softWrap: true,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(
                                    top: 20.0, bottom: 0, left: 20, right: 20),
                                child: Divider(
                                  thickness: 1.5,
                                ),
                              ),
                              if (locationInfo.tripbestModule != null)
                                TripbestSection(
                                    tripbests: locationInfo.tripbestModule!),
                              AttractionsSection(
                                  attractions: locationInfo.attractions,
                                  locationName: location.name),
                              RestaurantSection(
                                  restaurants: locationInfo.restaurants,
                                  locationName: location.name),
                              HotelSection(
                                  hotels: locationInfo.hotels,
                                  locationName: location.name),
                              const Padding(
                                padding: EdgeInsets.only(
                                    top: 20.0, bottom: 0, left: 20, right: 20),
                                child: Divider(
                                  thickness: 1.5,
                                ),
                              ),
                              if (locationInfo.comments != null)
                                CommentSection(
                                    comments: locationInfo.comments!,
                                    locationName: location.name),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
            return const Center(
              child: Text('Không có dữ liệu'),
            );
          },
        ),
      ),
    );
  }
}
