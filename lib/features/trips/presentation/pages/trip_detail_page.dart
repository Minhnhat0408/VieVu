import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/saved_services.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/saved_service_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip/trip_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/cubit/trip_details_cubit.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/trip_info_page.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/trip_itinerary_page.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/trip_saved_services_page.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/trip_settings_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/trip_todo_list_page.dart';
import 'package:vn_travel_companion/features/trips/presentation/widgets/trip_detail_appbar.dart';

class TripDetailPage extends StatefulWidget {
  static const String routeName = '/trip-detail';
  final Trip trip;
  const TripDetailPage({super.key, required this.trip});

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  Trip? trip;
  @override
  void initState() {
    super.initState();

    trip = widget.trip;

    context.read<TripDetailsCubit>().getTripDetails(tripId: widget.trip.id);
    context
        .read<SavedServiceBloc>()
        .add(GetSavedServices(tripId: widget.trip.id));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: BlocConsumer<TripDetailsCubit, TripDetailsState>(
          listener: (context, state) {
            // TODO: implement listener
            if (state is TripDetailsLoadedSuccess) {
              setState(() {
                trip = state.trip;
              });
            }
            if (state is TripDetailsLoadedFailure) {
              showSnackbar(context, state.message, 'error');
            }
          },
          builder: (context, state) {
            return BlocListener<TripBloc, TripState>(
              listener: (context, state) {
                if (state is TripActionSuccess) {
                  setState(() {
                    trip = state.trip;
                  });
                }
              },
              child: Stack(children: [
                NestedScrollView(
                    floatHeaderSlivers: false,
                    headerSliverBuilder: (context, innerBoxIsScrolled) => [
                          SliverOverlapAbsorber(
                              handle: NestedScrollView
                                  .sliverOverlapAbsorberHandleFor(context),
                              sliver: TripDetailAppbar(trip: trip)),
                        ],
                    body: TabBarView(children: [
                      TripInfoPage(trip: trip!),
                      TripSavedServicesPage(trip: trip!),
                      const TripItineraryPage(),
                      const TripTodoListPage(),
                    ])),
                Positioned.fill(
                    child: CircularMenu(
                        toggleButtonColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        alignment: const Alignment(0.95, 0.85),
                        toggleButtonIconColor:
                            Theme.of(context).colorScheme.primary,
                        startingAngleInRadian:
                            3.14, // Example: 180 degrees (π radians)
                        endingAngleInRadian:
                            3.14 * 3 / 2, // Example: 360 degrees (2π radians)
                        items: [
                      CircularMenuItem(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          icon: Icons.message,
                          iconColor: Theme.of(context).colorScheme.primary,
                          onTap: () {
                            // callback
                          }),
                      CircularMenuItem(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        icon: Icons.map_outlined,
                        onTap: () {
                          //callback
                        },
                        iconColor: Theme.of(context).colorScheme.primary,
                      ),
                      CircularMenuItem(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          icon: Icons.people_alt,
                          iconColor: Theme.of(context).colorScheme.primary,
                          onTap: () {
                            //callback
                          }),
                    ]))
              ]),
            );
          },
        ),
      ),
    );
  }
}
