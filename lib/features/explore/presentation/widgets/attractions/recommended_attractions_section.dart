import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/features/explore/domain/entities/attraction.dart';
import 'package:vievu/features/explore/presentation/bloc/attraction/attraction_bloc.dart';
import 'package:vievu/features/explore/presentation/pages/all_recommendations_page.dart';
import 'package:vievu/features/explore/presentation/widgets/attractions/attraction_big_card.dart';
import 'package:vievu/features/user_preference/presentation/bloc/preference/preference_bloc.dart';
import 'package:vievu/init_dependencies.dart';

class RecommendedAttractionSection extends StatefulWidget {
  final bool? refresh;
  const RecommendedAttractionSection({super.key, this.refresh});

  @override
  State<RecommendedAttractionSection> createState() =>
      _RecommendedAttractionSectionState();
}

class _RecommendedAttractionSectionState
    extends State<RecommendedAttractionSection> {
  final List<Attraction> attractions = [];
  @override
  void initState() {
    super.initState();
    context.read<AttractionBloc>().add(GetRecommendedAttraction(
        limit: 10,
        userPref:
            (context.read<PreferencesBloc>().state as PreferencesLoadedSuccess)
                .preference));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.refresh != null) {
      context.read<AttractionBloc>().add(GetRecommendedAttraction(
          limit: 10,
          userPref: (context.read<PreferencesBloc>().state
                  as PreferencesLoadedSuccess)
              .preference));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gợi ý cho bạn',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => serviceLocator<AttractionBloc>(),
                        child: const AllRecommendationsPage(),
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Xem tất cả',
                ),
              ),
            ],
          ),
        ),
        BlocConsumer<AttractionBloc, AttractionState>(
          listener: (context, state) {
            if (state is AttractionFailure) {
              // showSnackbar(context, state.message, 'error');
              log(state.message);
            }
          },
          builder: (context, state) {
            if (state is AttractionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AttractionsLoadedSuccess) {
              return SizedBox(
                height: 415, // Height for the horizontal list
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
