import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/reviews_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReviewsSection extends StatefulWidget {
  final int serviceId;
  final int totalReviews;
  const ReviewsSection({
    super.key,
    required this.serviceId,
    required this.totalReviews,
  });

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('vi', timeago.ViMessages());
    context
        .read<ReviewsCubit>()
        .fetchReviews(attractionId: widget.serviceId, limit: 3, pageIndex: 1);
  }

  String _translateTripType(String tripType) {
    return tripType == 'Solo'
        ? 'Du lịch một mình'
        : tripType == 'Couples'
            ? 'Du lịch cặp đôi'
            : tripType == 'Family'
                ? 'Du lịch gia đình'
                : 'Du lịch nhóm';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReviewsCubit, ReviewsState>(
      listener: (context, state) {
        if (state is ReviewsLoadedSuccess) {
          log(state.reviews.toString());
        }
      },
      builder: (context, state) {
        if (state is ReviewsLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is ReviewsLoadedSuccess) {
          if (state.reviews.isEmpty) {
            return const Center(
              child: Text("Không có đánh giá nào."),
            );
          }
          // Use a Column instead of ListView.builder for non-scrollable content
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // use 3 reviews for now

              ...state.reviews.take(4).map((review) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(review.avatar),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review.nickName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    timeago.format(review.createdAt,
                                        locale: 'vi'),
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          RatingBarIndicator(
                            rating: review.score,
                            itemSize: 24,
                            direction: Axis.horizontal,
                            itemCount: 5,
                            itemBuilder: (context, _) => Icon(
                              Icons.favorite,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review.content,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text(
                          'Loại chuyến đi: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _translateTripType(review.tripType),
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ],
                    ),
                    const Divider(
                      thickness: 1.5,
                      height: 60,
                    ),
                  ],
                );
              }),
              Center(
                child: SizedBox(
                  width: 300,
                  child: OutlinedButton(
                    onPressed: () {},
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
          );
        } else {
          return const Center(
            child: Text("Đã xảy ra lỗi khi tải đánh giá."),
          );
        }
      },
    );
  }
}
