import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:vn_travel_companion/core/layouts/custom_appbar.dart';
import 'package:vn_travel_companion/core/utils/display_modal.dart';
import 'package:vn_travel_companion/core/utils/open_url.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_itinerary.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_member.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip_itinerary/trip_itinerary_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/cubit/current_trip_member_info_cubit.dart';
import 'package:vn_travel_companion/features/trips/presentation/widgets/modals/add_note_to_itinerary_modal.dart';

class TripItineraryDetailPage extends StatefulWidget {
  final List<TripItinerary> itineraries;
  final int index;

  const TripItineraryDetailPage({
    super.key,
    required this.itineraries,
    required this.index,
  });

  @override
  State<TripItineraryDetailPage> createState() =>
      _TripItineraryDetailPageState();
}

class _TripItineraryDetailPageState extends State<TripItineraryDetailPage> {
  int index = 0;
  List<TripItinerary> itineraries = [];
  late TripMember? currentUser;

  @override
  void initState() {
    index = widget.index;
    currentUser = (context.read<CurrentTripMemberInfoCubit>().state
            as CurrentTripMemberInfoLoaded)
        .tripMember;
    itineraries = widget.itineraries;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbar(
      actions: [
        CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.onSurface,
          child: Text(
            (index + 1).toString(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.surface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 20),
      ],
      body: BlocListener<TripItineraryBloc, TripItineraryState>(
        listener: (context, state) {
          //
          if (state is TripItineraryUpdatedSuccess) {
            // change the updated itinerary in the list

            setState(() {
              final updatedItinerary = state.tripItinerary;
              itineraries[index] = updatedItinerary;
            });
          }
        },
        child: Column(
          children: [
            Expanded(
                child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (itineraries[index].service != null)
                    CachedNetworkImage(
                      imageUrl: itineraries[index].service?.cover ?? "",
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/images/trip_placeholder.avif',
                      ),
                      height: 300,
                      width: double.infinity,
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (itineraries[index].service != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            child: Text(
                              itineraries[index].service!.locationName,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Text(
                          itineraries[index].title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 32),
                        ),

                        if (itineraries[index].service != null &&
                            itineraries[index].service?.typeId != 5 &&
                            itineraries[index].service?.typeId != 0)
                          Column(
                            children: [
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  RatingBarIndicator(
                                    rating: itineraries[index].service!.rating,
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
                                  const SizedBox(width: 8),
                                  Text(
                                    '${itineraries[index].service!.ratingCount} đánh giá',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (itineraries[index].service!.hotelStar !=
                                      null)
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: RatingBarIndicator(
                                          itemSize: 24,
                                          direction: Axis.horizontal,
                                          rating: itineraries[index]
                                              .service!
                                              .hotelStar!
                                              .toDouble(),
                                          itemCount: widget.itineraries[index]
                                              .service!.hotelStar!,
                                          itemBuilder: (context, _) =>
                                              const Icon(Icons.star,
                                                  color: Color.fromARGB(
                                                      255, 255, 234, 44)),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),

                        if (itineraries[index].service?.tagInforList != null)
                          Column(
                            children: [
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                child: Text(
                                  itineraries[index].service!.tagInforList![0],
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                              ),
                            ],
                          ),
                        // Event Date
                        if (itineraries[index].service?.eventDate != null)
                          Column(
                            children: [
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(widget
                                        .itineraries[index]
                                        .service!
                                        .eventDate!),
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.timer_sharp,
                              size: 20,
                              color: Colors.cyan[200],
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              DateFormat('HH:mm dd/MM/yyyy')
                                  .format(itineraries[index].time),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            if (currentUser != null &&
                                currentUser!.role != 'member')
                              GestureDetector(
                                onTap: () async {
                                  await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  ).then((value) {
                                    if (value != null) {
                                      final newTime = DateTime(
                                        itineraries[index].time.year,
                                        itineraries[index].time.month,
                                        itineraries[index].time.day,
                                        value.hour,
                                        value.minute,
                                      );

                                      context
                                          .read<TripItineraryBloc>()
                                          .add(UpdateTripItinerary(
                                            id: itineraries[index].id,
                                            time: newTime,
                                          ));
                                    }
                                  });
                                },
                                child: const Icon(
                                  Icons.edit,
                                  size: 15,
                                ),
                              )
                          ],
                        ),
                        const SizedBox(height: 12),
                        RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: itineraries[index].note ??
                                    'Chưa có ghi chú',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const WidgetSpan(child: SizedBox(width: 6)),
                              if (currentUser != null &&
                                  currentUser!.role != 'member')
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: GestureDetector(
                                    onTap: () {
                                      displayModal(
                                          context,
                                          AddNoteToItineraryModal(
                                            tripItinerary: itineraries[index],
                                          ),
                                          null,
                                          false);
                                    },
                                    child: const Icon(
                                      Icons.edit,
                                      size: 15,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (widget.itineraries[widget.index].time
                            .isBefore(DateTime.now()))
                          // check box
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 10),
                            child: InputChip(
                              label: Text(
                                "Hoàn thành",
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.bold),
                              ),
                              selected: widget.itineraries[widget.index].isDone,
                              onSelected: (bool value) {
                                if (currentUser != null) {
                                  context.read<TripItineraryBloc>().add(
                                      UpdateTripItinerary(
                                          id: widget
                                              .itineraries[widget.index].id,
                                          isDone: value,
                                          time: widget
                                              .itineraries[widget.index].time));
                                  setState(() {
                                    widget.itineraries[widget.index].isDone =
                                        value;
                                  });
                                }
                              },
                              // selectedColor: Theme.of(context).colorScheme.primary,
                              // checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ),
            )),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      openDeepLink(
                          "https://www.google.com/maps?q=${itineraries[index].latitude},${itineraries[index].longitude}");
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      backgroundColor: Theme.of(context).colorScheme.onSurface,
                      foregroundColor: Theme.of(context).colorScheme.surface,
                    ),
                    child: IntrinsicWidth(
                      child: Row(
                        children: [
                          Image.asset('assets/icons/gg-pin.png',
                              width: 24, height: 24),
                          const SizedBox(
                            width: 10,
                          ),
                          const Text(
                            "Google Maps",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              if (index == 0) {
                                index = itineraries.length - 1;
                              } else {
                                index--;
                              }
                            });
                          },
                          label: const Icon(
                            Icons.chevron_left_rounded,
                            size: 30,
                          )),
                      const SizedBox(
                        width: 10,
                      ),
                      OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              if (index == itineraries.length - 1) {
                                index = 0;
                              } else {
                                index++;
                              }
                            });
                          },
                          label: const Icon(
                            Icons.chevron_right_rounded,
                            size: 30,
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
