import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/core/utils/display_modal.dart';
import 'package:vievu/features/explore/presentation/widgets/reviews/review_item.dart';
import 'package:vievu/features/trips/domain/entities/trip.dart';
import 'package:vievu/features/trips/domain/entities/trip_member.dart';
import 'package:vievu/features/trips/domain/entities/trip_review.dart';
import 'package:vievu/features/trips/presentation/bloc/trip_review_bloc.dart';
import 'package:vievu/features/trips/presentation/widgets/modals/post_review_modal.dart';
import 'package:vievu/features/trips/presentation/widgets/trip_review_item.dart';

class TripReviewPage extends StatefulWidget {
  final Trip trip;
  final TripMember? currentUser;
  const TripReviewPage({
    super.key,
    required this.trip,
    this.currentUser,
  });

  @override
  State<TripReviewPage> createState() => _TripReviewPageState();
}

class _TripReviewPageState extends State<TripReviewPage> {
  List<TripReview> tripReviews = [];

  @override
  void initState() {
    super.initState();
    if (context.read<TripReviewBloc>().state is TripReviewsLoadedSuccess) {
      final state =
          context.read<TripReviewBloc>().state as TripReviewsLoadedSuccess;
      setState(() {
        tripReviews = state.reviews;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double averageRating = tripReviews.isNotEmpty
        ? tripReviews.map((e) => e.rating).reduce((a, b) => a + b) /
            tripReviews.length
        : 0.0;

    // Count rating occurrences (from 5-star to 1-star)
    Map<int, int> ratingCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var review in tripReviews) {
      ratingCounts[review.rating.toInt()] = ratingCounts[review.rating]! + 1;
    }

    int maxCount = ratingCounts.values.isNotEmpty
        ? ratingCounts.values.reduce((a, b) => a > b ? a : b)
        : 1;
    return CustomScrollView(
      key: const PageStorageKey('trip-reviews-page'),
      slivers: [
        SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
        SliverAppBar(
          leading: null,
          primary: false,
          floating: true,
          title: widget.currentUser?.reviewed == false
              ? SizedBox(
                  height: 36, // Giới hạn chiều cao
                  child: Row(
                    children: [
                      FilledButton(
                          onPressed: () {
                            displayModal(
                              context,
                              PostReviewModal(
                                trip: widget.trip,
                                currentUser: widget.currentUser!,
                                initialRating: 0,
                              ),
                              null,
                              true,
                            );
                          },
                          child: const Text('Thêm đánh giá')),
                    ],
                  ),
                )
              : const Text(
                  'Đánh giá',
                  style: TextStyle(fontSize: 16),
                ),
          actions: const [
            // IconButton.outlined(
            //   onPressed: () {},
            //   icon: const Icon(Icons.filter_alt_sharp),
            // ),
            // const SizedBox(
            //   width: 10,
            // ),
          ],
          pinned: true,
          automaticallyImplyLeading: false,
        ),
        BlocConsumer<TripReviewBloc, TripReviewState>(
          listener: (context, state) {
            if (state is TripReviewsLoadedSuccess) {
              setState(() {
                tripReviews = state.reviews;
              });
            }

            if (state is TripReviewDeletedSuccess) {
              widget.currentUser!.reviewed = false;

              setState(() {
                tripReviews.removeWhere((element) => element.id == state.id);
              });
            }

            if (state is TripReviewUpsertedSuccess) {
              widget.currentUser!.reviewed = true;
              setState(() {
                tripReviews.insert(0, state.review);
              });
            }
          },
          builder: (context, state) {
            return state is TripReviewLoading
                ? const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : tripReviews.isNotEmpty
                    ? SliverPadding(
                        padding: const EdgeInsets.only(bottom: 70.0),
                        sliver: SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 20),
                            child: Column(children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left Column: Average Rating & Total Reviews
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            averageRating.toStringAsFixed(
                                                1), // Display 1 decimal place
                                            style: const TextStyle(
                                              fontSize: 40,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 40,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        '${tripReviews.length} đánh giá',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                      width: 20), // Space between columns
                                  // Right Column: Star Distribution
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: List.generate(5, (index) {
                                        int star = 5 - index;
                                        double percentage = maxCount > 0
                                            ? ratingCounts[star]! / maxCount
                                            : 0.0;
                                        return Row(
                                          children: [
                                            SizedBox(
                                              width: 10,
                                              child: Text("$star",
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                            const SizedBox(width: 5),
                                            const Icon(Icons.star,
                                                color: Colors.amber, size: 16),
                                            const SizedBox(width: 5),
                                            Expanded(
                                              child: LinearProgressIndicator(
                                                value: percentage,
                                                valueColor:
                                                    const AlwaysStoppedAnimation<
                                                        Color>(Colors.amber),
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            SizedBox(
                                              width: 10,
                                              child: Text(
                                                  "${ratingCounts[star]}",
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey)),
                                            ),
                                          ],
                                        );
                                      }),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Divider(),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: tripReviews.length,
                                itemBuilder: (context, index) {
                                  return TripReviewItem(
                                    review: tripReviews[index],
                                  );
                                },
                              ),
                            ]),
                          ),
                        ))
                    : const SliverFillRemaining(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 50.0, vertical: 50),
                          child: Column(
                            children: [
                              Icon(
                                Icons.star_border,
                                size: 100,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Chuyến đị hiện chưa có đánh giá nào. ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                      );
          },
        )
      ],
    );
  }
}
