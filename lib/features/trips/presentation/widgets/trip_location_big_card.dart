import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/core/utils/display_modal.dart';
import 'package:vn_travel_companion/features/explore/presentation/bloc/location/location_bloc.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/location_info/location_info_cubit.dart';
import 'package:vn_travel_companion/features/explore/presentation/pages/location_detail_page.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/saved_to_trip_modal.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/saved_services.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/saved_service/saved_service_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip/trip_bloc.dart';
import 'package:vn_travel_companion/init_dependencies.dart';

class TripLocationBigCard extends StatefulWidget {
  final SavedService tripLocation;
  const TripLocationBigCard({
    super.key,
    required this.tripLocation,
  });

  @override
  State<TripLocationBigCard> createState() => _TripLocationBigCardState();
}

class _TripLocationBigCardState extends State<TripLocationBigCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => serviceLocator<LocationBloc>(),
              child: LocationDetailPage(
                locationId: widget.tripLocation.id,
                locationName: widget.tripLocation.locationName,
              ),
            ),
          ),
        );
      },
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAlias,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image and Icon
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: "${widget.tripLocation.cover}?w=90&h=90",
                      fadeInDuration: const Duration(milliseconds: 200),
                      filterQuality: FilterQuality.low,
                      width: double.infinity,
                      height: 180,
                      useOldImageOnUrlChange: true,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                  BlocBuilder<LocationInfoCubit, LocationInfoState>(
                    builder: (context, state) {
                      return Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          onPressed: () {
                            final userId = (context.read<AppUserCubit>().state
                                    as AppUserLoggedIn)
                                .user
                                .id;
                            context.read<TripBloc>().add(GetSavedToTrips(
                                  userId: userId,
                                  id: widget.tripLocation.id,
                                ));
                            displayModal(context, SavedToTripModal(
                              onTripsChanged: (List<Trip> selectedTrips,
                                  List<Trip> unselectedTrips) {
                                for (var item in selectedTrips) {
                                  context
                                      .read<SavedServiceBloc>()
                                      .add(InsertSavedService(
                                        tripId: item.id,
                                        linkId: widget.tripLocation.id,
                                        cover: widget.tripLocation.cover,
                                        name: widget.tripLocation.name,
                                        locationName: widget.tripLocation.name,
                                        rating: 0,
                                        ratingCount: 0,
                                        typeId: 0,
                                        latitude: widget.tripLocation.latitude,
                                        longitude:
                                            widget.tripLocation.longitude,
                                      ));
                                }

                                for (var item in unselectedTrips) {
                                  context.read<SavedServiceBloc>().add(
                                      DeleteSavedService(
                                          linkId: widget.tripLocation.id,
                                          tripId: item.id));
                                }
                              },
                            ), null, false);
                          },
                          style: IconButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                          icon: const Icon(
                            Icons.favorite,
                            color: Colors.redAccent,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 6,
                    ),

                    AutoSizeText(
                      widget.tripLocation.locationName,
                      minFontSize: 14, // inimum font size to shrink to
                      maxLines: 2, // Allow up to 2 lines for wrapping
                      overflow: TextOverflow
                          .ellipsis, // Add ellipsis if it exceeds maxLines
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18, // Default starting font size
                      ),
                    ),

                    const SizedBox(height: 6),
                    // Rating
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
