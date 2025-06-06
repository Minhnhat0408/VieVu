import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:vievu/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vievu/core/utils/display_modal.dart';
import 'package:vievu/core/utils/open_url.dart';
import 'package:vievu/features/explore/presentation/cubit/location_info/location_info_cubit.dart';
import 'package:vievu/features/explore/presentation/pages/attraction_details_page.dart';
import 'package:vievu/features/explore/presentation/pages/location_detail_page.dart';
import 'package:vievu/features/explore/presentation/widgets/saved_to_trip_modal.dart';
import 'package:vievu/features/trips/domain/entities/saved_services.dart';
import 'package:vievu/features/trips/domain/entities/trip.dart';
import 'package:vievu/features/trips/presentation/bloc/saved_service/saved_service_bloc.dart';
import 'package:vievu/features/trips/presentation/bloc/trip/trip_bloc.dart';
import 'package:vievu/features/user_preference/presentation/bloc/preference/preference_bloc.dart';

class SavedServiceBigCard extends StatefulWidget {
  final SavedService service;
  // 1: Nhà hàng, 2: Địa điểm du lịch, 3: Cửa hàng, 4: Khách sạn, 5: Sự kiện,
  const SavedServiceBigCard({super.key, required this.service});

  @override
  State<SavedServiceBigCard> createState() => _SavedServiceBigCardState();
}

class _SavedServiceBigCardState extends State<SavedServiceBigCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.service.typeId == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AttractionDetailPage(attractionId: widget.service.id),
            ),
          );
        } else if (widget.service.typeId == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LocationDetailPage(
                locationId: widget.service.id,
                locationName: widget.service.locationName,
              ),
            ),
          );
        } else {
          if (widget.service.externalLink != null &&
              (widget.service.externalLink!.contains('http') ||
                  widget.service.externalLink!.contains('https'))) {
            openDeepLink(widget.service.externalLink!);
          } else {
            final String url =
                'https://vn.trip.com${widget.service.externalLink}';
            openDeepLink(url);
          }
        }
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
                      imageUrl: "${widget.service.cover}?w=90&h=90",
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
                                  id: widget.service.id,
                                ));
                            displayModal(context, SavedToTripModal(
                              onTripsChanged: (List<Trip> selectedTrips,
                                  List<Trip> unselectedTrips) {
                                if (selectedTrips.isNotEmpty &&
                                    widget.service.typeId == 2) {
                                  final currentPref = (context
                                          .read<PreferencesBloc>()
                                          .state as PreferencesLoadedSuccess)
                                      .preference;

                                  context.read<PreferencesBloc>().add(
                                      UpdatePreferenceDF(
                                          attractionId: widget.service.id,
                                          currentPref: currentPref,
                                          action: 'save'));
                                }
                                for (var item in selectedTrips) {
                                  context
                                      .read<SavedServiceBloc>()
                                      .add(InsertSavedService(
                                        tripId: item.id,
                                        linkId: widget.service.id,
                                        cover: widget.service.cover,
                                        name: widget.service.name,
                                        locationName:
                                            widget.service.locationName,
                                        rating: widget.service.rating,
                                        ratingCount: widget.service.ratingCount,
                                        typeId: widget.service.typeId,
                                        latitude: widget.service.latitude,
                                        longitude: widget.service.longitude,
                                      ));
                                }

                                for (var item in unselectedTrips) {
                                  context.read<SavedServiceBloc>().add(
                                      DeleteSavedService(
                                          linkId: widget.service.id,
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
                  if (widget.service.typeId == 4 &&
                      widget.service.hotelStar != null)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: RatingBarIndicator(
                          itemSize: 24,
                          direction: Axis.horizontal,
                          rating: widget.service.hotelStar!.toDouble(),
                          itemCount: widget.service.hotelStar!,
                          itemBuilder: (context, _) => const Icon(Icons.star,
                              color: Color.fromARGB(255, 255, 234, 44)),
                        ),
                      ),
                    )
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                      child: Text(
                        widget.service.locationName,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),

                    AutoSizeText(
                      widget.service.name,
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
                    if (widget.service.typeId != 5 &&
                        widget.service.typeId != 0)
                      Column(
                        children: [
                          Row(
                            children: [
                              RatingBarIndicator(
                                rating: widget.service.rating,
                                itemSize: 20,
                                direction: Axis.horizontal,
                                itemCount: 5,
                                itemBuilder: (context, _) => Icon(
                                  Icons.favorite,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                ),
                              ),
                              Text(
                                '(${widget.service.ratingCount})',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                        ],
                      ),
                    // Travel Types
                    if (widget.service.tagInforList != null)
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            child: Text(
                              widget.service.tagInforList![0],
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                      ),
                    // Price
                    if (widget.service.eventDate != null)
                      Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('dd/MM/yyyy')
                                    .format(widget.service.eventDate!),
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                        ],
                      ),

                    if (widget.service.price != null)
                      Text(
                        'Từ: ${NumberFormat('#,###').format(widget.service.price)} VND',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
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
