import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:vievu/features/trips/domain/entities/trip_member.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/features/trips/presentation/bloc/trip_member/trip_member_bloc.dart';

class UserRatingModal extends StatefulWidget {
  final String userId;
  const UserRatingModal({
    super.key,
    required this.userId,
  });

  @override
  State<UserRatingModal> createState() => _UserRatingModalState();
}

class _UserRatingModalState extends State<UserRatingModal> {
  final List<TripMemberRating> reviews = [];
  List<bool> _expanded = [];
  final Map<String, Map<String, String>> _trips = {}; // tripId as key

  @override
  void initState() {
    super.initState();
    context.read<TripMemberBloc>().add(GetRatedUsers(userId: widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: const Text('Người dùng đánh giá'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: BlocConsumer<TripMemberBloc, TripMemberState>(
        listener: (context, state) {
          if (state is UsersRatedLoadedSuccess) {
            reviews.clear();
            reviews.addAll(state.users);

            _trips.clear();
            for (var e in reviews) {
              _trips[e.tripId] = {
                'id': e.tripId,
                'name': e.tripName,
                'cover': e.tripCover,
              };
            }

            _expanded = List.generate(_trips.length, (index) => false);
          }
        },
        builder: (context, state) {
          if (state is TripMemberLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (reviews.isEmpty) {
            return const Center(child: Text("Không có đánh giá."));
          }

          final tripsList = _trips.values.toList();

          return ListView(
            children: [
              ExpansionPanelList(
                expandedHeaderPadding: EdgeInsets.zero,
                expansionCallback: (int index, bool isExpanded) {
                  log('index: $index, isExpanded: $isExpanded');
                  setState(() {
                    _expanded[index] = isExpanded;
                  });
                },
                animationDuration: const Duration(milliseconds: 500),
                children: tripsList.asMap().entries.map((entry) {
                  final index = entry.key;
                  final trip = entry.value;
                  final tripReviews =
                      reviews.where((r) => r.tripId == trip['id']).toList();

                  return ExpansionPanel(
                    canTapOnHeader: true,
                    isExpanded: _expanded[index],
                    headerBuilder: (context, isExpanded) => ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          trip['cover'] ?? '',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      title: Text(
                        trip['name'] ?? '',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    body: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: tripReviews.map((rater) {
                          return ListTile(
                            leading: CachedNetworkImage(
                              imageUrl: rater.user.avatarUrl ?? '',
                              imageBuilder: (context, imageProvider) =>
                                  CircleAvatar(
                                radius: 20,
                                backgroundImage: imageProvider,
                              ),
                              errorWidget: (context, url, error) =>
                                  const CircleAvatar(
                                radius: 20,
                                child: Icon(
                                  Icons.person,
                                  size: 20,
                                ), // Change this to your desired border color
                              ),
                              fit: BoxFit.cover,
                              width: 40,
                              height: 40,
                            ),
                            title: Text(
                                "${rater.user.lastName} ${rater.user.firstName}"),
                            // subtitle: Text(rater.tripName),
                            trailing: RatingBarIndicator(
                              rating: rater.rating.toDouble(),
                              itemSize: 24,
                              direction: Axis.horizontal,
                              itemCount: 5,
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }).toList(),
              )
            ],
          );
        },
      ),
    );
  }
}
