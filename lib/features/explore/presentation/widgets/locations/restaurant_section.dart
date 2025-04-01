import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/features/explore/domain/entities/restaurant.dart';
import 'package:vievu/features/explore/presentation/bloc/location/location_bloc.dart';
import 'package:vievu/features/explore/presentation/cubit/nearby_services/nearby_services_cubit.dart';
import 'package:vievu/features/explore/presentation/pages/restaurant_list_page.dart';
import 'package:vievu/features/explore/presentation/widgets/locations/restaurant_big_card.dart';
import 'package:vievu/init_dependencies.dart';

class RestaurantSection extends StatelessWidget {
  final List<Restaurant> restaurants;

  const RestaurantSection({
    super.key,
    required this.restaurants,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        if (state is LocationLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is LocationDetailsLoadedSuccess) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nhà hàng',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        BlocProvider(
                                  create: (context) =>
                                      serviceLocator<NearbyServicesCubit>(),
                                  child: RestaurantListPage(
                                    locationName: state.location.name,
                                    locationId: state.location.id,
                                    latitude: state.location.latitude,
                                    longitude: state.location.longitude,
                                  ),
                                ),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  return child; // No transition for the rest of the page
                                },
                              ),
                            );
                          },
                          child: Text(
                            'Xem tất cả',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Nhà hàng, quán ăn, quán cà phê và quán bar xuất sắc tại ${state.location.name}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 400, // Height for the horizontal list
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: restaurants.length, // Number of items
                  itemBuilder: (context, index) {
                    return Padding(
                        padding: EdgeInsets.only(
                          left: index == 0
                              ? 20.0
                              : 4.0, // Extra padding for the first item
                          right: index == restaurants.length - 1
                              ? 20.0
                              : 4.0, // Extra padding for the last item
                        ),
                        child:
                            RestaurantBigCard(restaurant: restaurants[index]));
                  },
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
