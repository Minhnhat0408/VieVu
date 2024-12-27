import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/features/explore/presentation/bloc/attraction/attraction_bloc.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/attractions/attraction_big_card.dart';

class RelatedAttractionSection extends StatefulWidget {
  final int attractionId;
  const RelatedAttractionSection({
    super.key,
    required this.attractionId,
  });

  @override
  State<RelatedAttractionSection> createState() =>
      _RelatedAttractionSectionState();
}

class _RelatedAttractionSectionState extends State<RelatedAttractionSection> {
  @override
  void initState() {
    super.initState();

    context.read<AttractionBloc>().add(
        GetRelatedAttractions(limit: 10, attractionId: widget.attractionId));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'Có thể bạn quan tâm',
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        BlocConsumer<AttractionBloc, AttractionState>(
          listener: (context, state) {
            if (state is AttractionFailure) {
              showSnackbar(context, state.message, 'error');
            }
          },
          builder: (context, state) {
            if (state is AttractionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AttractionsLoadedSuccess) {
              return SizedBox(
                height: 400, // Height for the horizontal list
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.attractions.length, // Number of items
                  itemBuilder: (context, index) {
                    log(state.attractions[index].price.toString());

                    return Padding(
                      padding: EdgeInsets.only(
                        left: index == 0
                            ? 0
                            : 4.0, // Extra padding for the first item
                        right: index == 9
                            ? 0
                            : 4.0, // Extra padding for the last item
                      ),
                      child: AttractionBigCard(
                        attraction: state.attractions[index],
                      ),
                    );
                  },
                ),
              );
            }
            return const SizedBox(
                height: 120, child: Center(child: Text('Không có dữ liệu')));
          },
        ),
      ],
    );
  }
}
