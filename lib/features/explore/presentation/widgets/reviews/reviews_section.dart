import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/review.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/reviews/reviews_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:vn_travel_companion/features/explore/presentation/pages/reviews_page.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/reviews/review_item.dart';
import 'package:vn_travel_companion/init_dependencies.dart';

class ReviewsSection extends StatefulWidget {
  final int serviceId;
  final int totalReviews;
  final double? avgRating;
  final Key reviewsSectionKey;
  const ReviewsSection({
    super.key,
    required this.serviceId,
    required this.totalReviews,
    required this.avgRating,
    required this.reviewsSectionKey,
  });

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  List<Review>? reviews;
  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('vi', timeago.ViMessages());
    context.read<ReviewsCubit>().fetchReviews(
        attractionId: widget.serviceId,
        limit: 3,
        pageIndex: 1,
        commentTagId: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          key: widget.reviewsSectionKey,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đánh giá từ cộng đồng',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.heartCirclePlus,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${widget.avgRating}/5",
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 30),
        BlocConsumer<ReviewsCubit, ReviewsState>(
          listener: (context, state) {
            if (state is ReviewsFailure) {
              log(state.message.toString());
            }
            if (state is ReviewsLoadedSuccess) {
              setState(() {
                final a = state.reviews.take(3).toList();
                reviews = a;
              });
            }
          },
          builder: (context, state) {
            if (state is ReviewsLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (reviews != null) {
              if (reviews!.isEmpty) {
                return const SizedBox(
                  height: 100,
                  child: Center(
                    child: Text("Không có đánh giá nào."),
                  ),
                );
              }
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.builder(
                      shrinkWrap: true, // Adjust to the size of its contents
                      physics:
                          const NeverScrollableScrollPhysics(), // Prevent nested scrolling issues
                      itemCount: reviews!.length,
                      padding: const EdgeInsets.all(0),
                      itemBuilder: (context, index) {
                        return ReviewItem(review: reviews![index]);
                      },
                    ),
                    Center(
                      child: SizedBox(
                        width: 300,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (context) =>
                                      serviceLocator<ReviewsCubit>(),
                                  child: ReviewsPage(
                                    attractionId: widget.serviceId,
                                  ),
                                ),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            'Xem tất cả ${widget.totalReviews} đánh giá',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            } else {
              return const SizedBox(
                height: 100,
                child: Center(
                  child: Text("Đã xảy ra lỗi khi tải đánh giá."),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
