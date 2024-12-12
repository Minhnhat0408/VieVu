import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/features/explore/presentation/bloc/explore_bloc.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/attraction_big_card.dart';

class HotAttractionsSection extends StatefulWidget {
  const HotAttractionsSection({super.key});

  @override
  State<HotAttractionsSection> createState() => _HotAttractionsSectionState();
}

class _HotAttractionsSectionState extends State<HotAttractionsSection> {
  @override
  void initState() {
    super.initState();
    context.read<ExploreBloc>().add(GetHotAttractions(limit: 10, offset: 0));
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Trải nghiệm hàng đầu ở Việt Nam',
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        BlocConsumer<ExploreBloc, ExploreState>(
          listener: (context, state) {
            // TODO: implement listener
            if (state is ExploreFailure) {
              showSnackbar(context, state.message, 'error');
            }
          },
          builder: (context, state) {
            if (state is ExploreLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AttractionsLoadedSuccess) {
              return SizedBox(
                height: 410, // Height for the horizontal list
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.attractions.length, // Number of items
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        left: index == 0
                            ? 20.0
                            : 4.0, // Extra padding for the first item
                        right: index == 9
                            ? 20.0
                            : 4.0, // Extra padding for the last item
                      ),
                      child: AttractionCard(
                        attraction: state.attractions[index],
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
