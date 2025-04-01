import 'package:flutter/material.dart';
import 'package:vievu/features/explore/domain/entities/comment.dart';
import 'package:vievu/features/explore/presentation/widgets/locations/comment_card.dart';

class CommentSection extends StatelessWidget {
  final List<Comment> comments;
  final String locationName;
  const CommentSection({
    super.key,
    required this.comments,
    required this.locationName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đánh giá',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Mọi người nói gì về $locationName và những trải nghiệm ở đây',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 300, // Height for the horizontal list
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: comments.length, // Number of items
            itemBuilder: (context, index) {
              return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0
                        ? 20.0
                        : 4.0, // Extra padding for the first item
                    right: index == comments.length - 1
                        ? 20.0
                        : 4.0, // Extra padding for the last item
                  ),
                  child: CommentCard(
                    comment: comments[index],
                  ));
            },
          ),
        ),
      ],
    );
  }
}
