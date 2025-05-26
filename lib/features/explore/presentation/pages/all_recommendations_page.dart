
import 'package:flutter/material.dart';
import 'package:vievu/core/layouts/custom_appbar.dart';
import 'package:vievu/core/utils/display_modal.dart';
import 'package:vievu/features/explore/presentation/bloc/attraction/attraction_bloc.dart';
import 'package:vievu/features/explore/presentation/widgets/attractions/attraction_med_card.dart';
import 'package:vievu/features/explore/presentation/widgets/attractions/attraction_pref_filter_modal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/features/user_preference/domain/entities/preference.dart';
import 'package:vievu/features/user_preference/presentation/bloc/preference/preference_bloc.dart';

class AllRecommendationsPage extends StatefulWidget {
  const AllRecommendationsPage({super.key});

  @override
  State<AllRecommendationsPage> createState() => _AllRecommendationsPageState();
}

class _AllRecommendationsPageState extends State<AllRecommendationsPage> {
  late Preference currentPref;
  Map<String, double> newPref = {};
  @override
  void initState() {
    super.initState();

    context.read<AttractionBloc>().add(GetRecommendedAttraction(
          limit: 40,
          userPref: (context.read<PreferencesBloc>().state
                  as PreferencesLoadedSuccess)
              .preference,
        ));

    currentPref =
        (context.read<PreferencesBloc>().state as PreferencesLoadedSuccess)
            .preference;

    newPref = Map<String, double>.from(currentPref.prefsDF);
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbar(
      appBarTitle: 'Tất cả gợi ý',
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_alt_outlined),
          onPressed: () {
            displayModal(context, AttractionPrefFilterModal(prefsDF: newPref),
                    null, true)
                .then((value) {
              if (value != null) {
                final newPref = value as Map<String, double>;
                setState(() {
                  this.newPref = newPref;
                });
                context.read<AttractionBloc>().add(GetRecommendedAttraction(
                    limit: 40,
                    userPref: Preference(
                      prefsDF: newPref,
                      budget: currentPref.budget,
                      avgRating: currentPref.avgRating,
                      ratingCount: currentPref.ratingCount,
                    )));
              }
            });
          },
        ),
      ],
      body: BlocConsumer<AttractionBloc, AttractionState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is AttractionsLoadedSuccess) {
            return ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return AttractionMedCard(attraction: state.attractions[index]);
              },
              itemCount: state.attractions.length,
            );
          }

          if (state is AttractionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return const Center(
            child: Text('Không có dữ liệu'),
          );
        },
      ),
    );
  }
}
