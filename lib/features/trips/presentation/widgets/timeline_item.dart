import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:vn_travel_companion/core/utils/display_modal.dart';
import 'package:vn_travel_companion/core/utils/open_url.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_itinerary.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_member.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip_itinerary/trip_itinerary_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/cubit/current_trip_member_info_cubit.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/trip_itinerary_detail_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TimelineItem extends StatefulWidget {
  final List<TripItinerary> itineraries;
  // final bool isOngoing;
  final int index;

  final DateTime panel;
  const TimelineItem({
    super.key,
    required this.panel,
    required this.itineraries,
    required this.index,
    // required this.isOngoing,
  });

  @override
  State<TimelineItem> createState() => _TimelineItemState();
}

class _TimelineItemState extends State<TimelineItem> {
  late TripMember? currentUser;
  @override
  void initState() {
    currentUser = (context.read<CurrentTripMemberInfoCubit>().state
            as CurrentTripMemberInfoLoaded)
        .tripMember;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 4, bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.itineraries[widget.index].title,
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 6,
          ),
          GestureDetector(
            onTap: () {
              openDeepLink(
                  "https://www.google.com/maps?q=${widget.itineraries[widget.index].latitude},${widget.itineraries[widget.index].longitude}");
            },
            child: IntrinsicWidth(
              child: Row(
                children: [
                  Image.asset('assets/icons/gg-pin.png', width: 20, height: 20),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Xem trên Google Maps",
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 6,
          ),
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
                intl.DateFormat('HH:mm')
                    .format(widget.itineraries[widget.index].time),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
          const SizedBox(
            height: 6,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.notes,
                size: 20,
                color: Colors.amber[200],
              ),
              const SizedBox(
                width: 10,
              ),
              Flexible(
                  child: Text(
                widget.itineraries[widget.index].note ?? "Chưa có ghi chú",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: () {
              displayFullScreenModal(
                  context,
                  TripItineraryDetailPage(
                    itineraries: widget.itineraries,
                    index: widget.index,
                  ));
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Xem chi tiết',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(
                  width: 6,
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                )
              ],
            ),
          ),
          if (widget.itineraries[widget.index].time.isBefore(DateTime.now()))
            // check box
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: InputChip(
                label: Text(
                  "Hoàn thành",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold),
                ),
                selected: widget.itineraries[widget.index].isDone,
                onSelected: (bool value) {
                  if (currentUser != null) {
                    context.read<TripItineraryBloc>().add(UpdateTripItinerary(
                        id: widget.itineraries[widget.index].id,
                        isDone: value,
                        time: widget.itineraries[widget.index].time));
                    setState(() {
                      widget.itineraries[widget.index].isDone = value;
                    });
                  }
                },
                // selectedColor: Theme.of(context).colorScheme.primary,
                // checkmarkColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
        ],
      ),
    );
  }
}
