import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/features/explore/presentation/bloc/location/location_bloc.dart';

class HotLocationsSection extends StatefulWidget {
  const HotLocationsSection({super.key});

  @override
  State<HotLocationsSection> createState() => _HotLocationsSectionState();
}

class _HotLocationsSectionState extends State<HotLocationsSection> {
  @override
  void initState() {
    super.initState();
    context.read<LocationBloc>().add(GetHotLocations(limit: 3, offset: 0));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Điểm đến được khách du lịch yêu thích',
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        BlocConsumer<LocationBloc, LocationState>(
          listener: (context, state) {
            if (state is LocationFailure) {
              showSnackbar(context, state.message, 'error');
            }
          },
          builder: (context, state) {
            if (state is LocationLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is LocationsLoadedSuccess) {
              return SizedBox(
                height: screenWidth, // Make height equal to screen width
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable scrolling
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 columns
                    crossAxisSpacing: 16, // Spacing between columns
                    mainAxisSpacing: 16, // Spacing between rows
                    childAspectRatio: 1, // Makes each item a square
                  ),
                  itemCount: state.locations.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius:
                          BorderRadius.circular(12), // Rounded corners
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: state.locations[index].cover,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.5),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                state.locations[index].name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }
            return const Center(child: Text('Không có dữ liệu'));
          },
        ),
      ],
    );
  }
}
