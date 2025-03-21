import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:vn_travel_companion/core/utils/conversions.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_member.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip_review_bloc.dart';

class PostReviewModal extends StatefulWidget {
  final Trip trip;
  final TripMember currentUser;
  final int initialRating;
  const PostReviewModal(
      {super.key,
      required this.trip,
      required this.currentUser,
      required this.initialRating});

  @override
  State<PostReviewModal> createState() => _PostReviewModalState();
}

class _PostReviewModalState extends State<PostReviewModal> {
  int rating = 0;
  final descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          leading: CachedNetworkImage(
              imageUrl: widget.trip.cover ?? '',
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              width: 50,
              height: 50,
              fit: BoxFit.cover),
          title: Text(widget.trip.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              )),
          subtitle: const Text('Đánh giá chuyến đi này'),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
          ),
        ),
        toolbarHeight: 80,
        leadingWidth: 30,
        actions: [
          TextButton(
            onPressed: () {
              // check if rating is 0
              if (rating != 0) {
                context.read<TripReviewBloc>().add(
                      UpsertTripReview(
                        tripId: widget.trip.id,
                        rating: rating.toDouble(),
                        review: descriptionController.text.isEmpty
                            ? null
                            : descriptionController.text,
                        memberId: widget.currentUser.id,
                      ),
                    );
                Navigator.of(context).pop('Đã đánh giá');
              } else {
                showSnackbar(context, 'Vui lòng dánh giá mưc độ hài lòng',
                    SnackBarState.warning);
              }
            },
            child: const Text('Đăng'),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          ListTile(
            leading: CachedNetworkImage(
              imageUrl: widget.currentUser.user.avatarUrl ?? '  ',
              imageBuilder: (context, imageProvider) => CircleAvatar(
                radius: 25,
                backgroundImage: imageProvider,
              ),
              height: 50,
              width: 50,
              placeholder: (context, url) => const CircleAvatar(
                child: Icon(Icons.person),
              ),
              errorWidget: (context, url, error) => const CircleAvatar(
                child: Icon(Icons.person),
              ),
            ),
            title: Text(
                "${widget.currentUser.user.lastName} ${widget.currentUser.user.firstName}"),
            subtitle: Text(convertRoleToString(widget.currentUser.role),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12)),
          ),
          const SizedBox(
            height: 20,
          ),
          RatingBarIndicator(
            rating: rating.toDouble(),
            itemSize: 50,
            direction: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, _) => GestureDetector(
              onTap: () {
                setState(() {
                  rating = _ + 1;
                });
              },
              child: const Icon(
                Icons.star,
                color: Colors.amber,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đánh giá', // Label always on top
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(height: 8), // Space between label and input box
                TextField(
                  onChanged: (value) => setState(() {}),
                  maxLines: 5,
                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                  controller: descriptionController,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    hintText: 'Viết đánh giá vể chuyến đi (tùy chọn)',
                  ),
                  // validator: Validators.check1000Characters,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
