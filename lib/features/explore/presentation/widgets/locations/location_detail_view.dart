import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/explore/presentation/bloc/location/location_bloc.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/location_info_cubit.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/locations/restaurant_section.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/locations/sub_location_section.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/locations/tripbest_section.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/slider_pagination.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/locations/attraction_section.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/locations/comment_section.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/locations/hotel_section.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/location.dart';

class LocationDetailView extends StatefulWidget {
  final int locationId;
  const LocationDetailView({super.key, required this.locationId});

  @override
  State<LocationDetailView> createState() => _LocationDetailViewState();
}

class _LocationDetailViewState extends State<LocationDetailView> {
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
    return BlocConsumer<LocationBloc, LocationState>(
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

          return BlocBuilder<LocationInfoCubit, LocationInfoState>(
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
              final locationInfo = (state2 as LocationInfoLoaded).locationInfo;
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              location.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 32),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
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
                          if (location.childLoc.isNotEmpty)
                            SubLocationSection(
                                locations: location.childLoc,
                                locationName: location.name),
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
    );
  }
}
