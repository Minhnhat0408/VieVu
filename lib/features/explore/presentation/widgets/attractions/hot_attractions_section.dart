import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vievu/core/utils/show_snackbar.dart';
import 'package:vievu/features/explore/domain/entities/attraction.dart';
import 'package:vievu/features/explore/presentation/bloc/attraction/attraction_bloc.dart';
import 'package:vievu/features/explore/presentation/widgets/attractions/attraction_big_card.dart';

class HotAttractionsSection extends StatefulWidget {
  const HotAttractionsSection({super.key});

  @override
  State<HotAttractionsSection> createState() => _HotAttractionsSectionState();
}

class _HotAttractionsSectionState extends State<HotAttractionsSection> {
  List<Attraction>? attractions;
  @override
  void initState() {
    super.initState();
    final userId =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
    context
        .read<AttractionBloc>()
        .add(GetHotAttractions(limit: 10, offset: 0, userId: userId));
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
        BlocConsumer<AttractionBloc, AttractionState>(
          listener: (context, state) {
            if (state is AttractionFailure) {
              showSnackbar(context, state.message, 'error');
            }
            if (state is AttractionsLoadedSuccess) {
              setState(() {
                attractions = state.attractions;
              });
            }
          },
          builder: (context, state) {
            if (state is AttractionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AttractionsLoadedSuccess && attractions != null) {
              return SizedBox(
                height: 400, // Height for the horizontal list
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,

                  itemCount: attractions!.length, // Number of items
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
                        attraction: attractions![index],
                        onSavedChanged: (bool saveState) {
                          setState(() {
                            // replace the saved status of the attraction by attraction 's id
                            attractions![index].isSaved = saveState;
                          });
                        },
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
