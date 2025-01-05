import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/service.dart';
import 'package:vn_travel_companion/features/explore/presentation/bloc/attraction/attraction_bloc.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/attraction_details/attraction_details_cubit.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/nearby_services/nearby_services_cubit.dart';
import 'package:vn_travel_companion/features/explore/presentation/pages/attraction_list_page.dart';
import 'package:vn_travel_companion/features/explore/presentation/pages/hotel_list_page.dart';
import 'package:vn_travel_companion/features/explore/presentation/pages/restaurant_list_page.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/attractions/service_card.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/filter_options_big.dart';
import 'package:vn_travel_companion/init_dependencies.dart';

class NearbyServiceSection extends StatefulWidget {
  final int attractionId;
  final String attractionName;
  const NearbyServiceSection(
      {super.key, required this.attractionId, required this.attractionName});

  @override
  State<NearbyServiceSection> createState() => _NearbyServiceSectionState();
}

class _NearbyServiceSectionState extends State<NearbyServiceSection> {
  final List<String> _filterOptions = [
    'Địa điểm du lịch',
    'Nhà hàng',
    'Khách sạn',
    'Cửa hàng',
  ];

  Map<String, List<Service>?> services = {
    'Nhà hàng': null,
    'Địa điểm du lịch': null,
    'Khách sạn': null,
    'Cửa hàng': null,
  };

  String _selectedFilter = 'Địa điểm du lịch';

  int _convertFilterToServiceType(String filter) {
    return filter == 'Nhà hàng'
        ? 1
        : filter == 'Địa điểm du lịch'
            ? 2
            : filter == 'Khách sạn'
                ? 4
                : 3;
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });

    if (services[filter] == null) {
      context.read<NearbyServicesCubit>().getServicesNearAttraction(
          attractionId: widget.attractionId,
          limit: 5,
          offset: 1,
          serviceType: _convertFilterToServiceType(filter),
          filterType: 'nearby10KM');
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<NearbyServicesCubit>().getServicesNearAttraction(
        attractionId: widget.attractionId,
        limit: 5,
        offset: 1,
        serviceType: 2,
        filterType: 'nearby10KM');
  }

  @override
  Widget build(BuildContext context) {
    log(services.toString());
    return BlocConsumer<NearbyServicesCubit, NearbyServicesState>(
      listener: (context, state) {
        if (state is NearbyServicesFailure) {
          showSnackbar(context, state.message, 'error');
        }

        if (state is NearbyServicesLoadedSuccess) {
          // log(state.services.toString());
          setState(() {
            services[_selectedFilter] = state.services;
          });
        }
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dịch vụ lân cận',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: FilterOptionsBig(
                    options: _filterOptions,
                    selectedOption: _selectedFilter,
                    outerPadding: 0,
                    onOptionSelected: _onFilterChanged,
                    isFiltering: state is NearbyServicesLoading)),
            if (state is NearbyServicesLoading)
              const SizedBox(
                height: 300,
                width: double.infinity,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            if (state is NearbyServicesLoadedSuccess)
              SingleChildScrollView(
                child: Column(
                  children: List.generate(
                    services[_selectedFilter]?.length ?? 0,
                    (index) {
                      final service = services[_selectedFilter]![index];
                      return ServiceCard(
                          service: service, type: _selectedFilter);
                    },
                  ),
                ),
              ),
            if (state is NearbyServicesLoadedSuccess &&
                services[_selectedFilter] != null &&
                services[_selectedFilter]!.length == 5)
              Center(
                child: Container(
                  padding: const EdgeInsets.only(top: 20),
                  width: 300,
                  child: OutlinedButton(
                    onPressed: () {
                      final long = (context.read<AttractionDetailsCubit>().state
                              as AttractionDetailsLoadedSuccess)
                          .attraction
                          .longitude;
                      final lat = (context.read<AttractionDetailsCubit>().state
                              as AttractionDetailsLoadedSuccess)
                          .attraction
                          .latitude;
                      if (_selectedFilter == 'Địa điểm du lịch') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                  create: (context) =>
                                      serviceLocator<AttractionBloc>(),
                                  child: AttractionListPage(
                                    latitude: lat,
                                    longitude: long,
                                  ))),
                        );
                      } else if (_selectedFilter == 'Nhà hàng') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                  create: (context) =>
                                      serviceLocator<NearbyServicesCubit>(),
                                  child: RestaurantListPage(
                                    latitude: lat,
                                    longitude: long,
                                  ))),
                        );
                      } else if (_selectedFilter == 'Khách sạn') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                  create: (context) =>
                                      serviceLocator<NearbyServicesCubit>(),
                                  child: HotelListPage(
                                    locationName: widget.attractionName,
                                  ))),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.onSurface,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      'Xem tất cả $_selectedFilter',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            if (state is NearbyServicesLoadedSuccess &&
                services[_selectedFilter]!.isEmpty)
              const SizedBox(
                height: 200,
                width: double.infinity,
                child: Center(
                  child: Text('Không tìm thấy dữ liệu'),
                ),
              ),
          ],
        );
      },
    );
  }
}
