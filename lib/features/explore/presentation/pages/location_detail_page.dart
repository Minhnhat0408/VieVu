import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vn_travel_companion/core/layouts/custom_appbar.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/location.dart';
import 'package:vn_travel_companion/features/explore/presentation/bloc/location/location_bloc.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/attraction_details/attraction_details_cubit.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.locationName,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share the attraction
            },
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border))
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
              child: Row(
                children: List.generate(
                  10, // Number of buttons
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: OutlinedButton(
                      onPressed: () {
                        // Button action
                      },
                      child: Text('Button ${index + 1}'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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
            final imgList = location.images != null
                ? [...location.images, location.cover]
                : [location.cover];

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
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 20, bottom: 80),
                    child: Column(
                      children: [
                        Text(
                          location.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 32),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(
            child: Text('Không có dữ liệu'),
          );
        },
      ),
    );
  }
}
