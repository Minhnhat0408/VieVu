import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/core/utils/display_modal.dart';
import 'package:vn_travel_companion/features/auth/presentation/pages/profile_page.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_review.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip_review_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/widgets/modals/post_review_modal.dart';

class TripReviewItem extends StatefulWidget {
  final TripReview review;
  const TripReviewItem({super.key, required this.review});

  @override
  State<TripReviewItem> createState() => _ReviewItemState();
}

class _ReviewItemState extends State<TripReviewItem> {
  bool _showFull = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(
                        id: widget.review.user.id,
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    CachedNetworkImage(
                      imageUrl: widget.review.user.avatarUrl ??
                          'https://via.placeholder.com/150',
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        radius: 20,
                        backgroundImage: imageProvider,
                      ),
                      height: 40,
                      width: 40,
                      placeholder: (context, url) => const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${widget.review.user.lastName} ${widget.review.user.firstName}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          timeago.format(widget.review.createdAt, locale: 'vi'),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                onSelected: (item) async {
                  if (item == "delete") {
                    context.read<TripReviewBloc>().add(
                          DeleteTripReview(
                            id: widget.review.id,
                          ),
                        );
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                  if (widget.review.user.id ==
                      (context.read<AppUserCubit>().state as AppUserLoggedIn)
                          .user
                          .id)
                    PopupMenuItem(
                        value: "edit",
                        child: ListTile(
                          leading: Icon(Icons.edit,
                              color: Theme.of(context).colorScheme.primary),
                          title: const Text('Chỉnh sửa'),
                        )),
                  if (widget.review.user.id !=
                      (context.read<AppUserCubit>().state as AppUserLoggedIn)
                          .user
                          .id)
                    PopupMenuItem(
                        value: "report",
                        child: ListTile(
                          leading: Icon(Icons.report,
                              color: Theme.of(context).colorScheme.primary),
                          title: const Text('Báo cáo'),
                        )),
                  if (widget.review.user.id ==
                      (context.read<AppUserCubit>().state as AppUserLoggedIn)
                          .user
                          .id)
                    const PopupMenuItem(
                        value: "delete",
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title:
                              Text('Xóa', style: TextStyle(color: Colors.red)),
                        )),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        RatingBarIndicator(
          rating: widget.review.rating,
          itemSize: 24,
          direction: Axis.horizontal,
          itemCount: 5,
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
        ),
        const SizedBox(height: 8),
        if (widget.review.review != null)
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: _showFull
                      ? widget.review.review
                      : widget.review.review!.length > 150
                          ? '${widget.review.review!.substring(0, 150)}...'
                          : widget.review.review, // Adjust length
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                if (!_showFull && widget.review.review!.length > 150)
                  TextSpan(
                    text: ' Xem thêm',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        setState(() {
                          _showFull = true;
                        });
                      },
                  ),
              ],
            ),
          ),
        const SizedBox(
          height: 50,
        ),
        // const Divider(
        //   thickness: 1.5,
        //   height: 60,
        // ),
      ],
    );
  }
}
