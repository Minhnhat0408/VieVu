import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:vn_travel_companion/core/common/pages/image_carousel_page.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/review.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReviewItem extends StatefulWidget {
  final Review review;
  const ReviewItem({super.key, required this.review});

  @override
  State<ReviewItem> createState() => _ReviewItemState();
}

class _ReviewItemState extends State<ReviewItem> {
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
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(widget.review.avatar),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.review.nickName,
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
              RatingBarIndicator(
                rating: widget.review.score,
                itemSize: 24,
                direction: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, _) => Icon(
                  Icons.favorite,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),
        //
        if (widget.review.tagName != null)
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              widget.review.tagName!,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: _showFull
                    ? widget.review.content
                    : widget.review.content.length > 150
                        ? '${widget.review.content.substring(0, 150)}...'
                        : widget.review.content, // Adjust length
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              if (!_showFull && widget.review.content.length > 150)
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

        const SizedBox(height: 8),
        Row(
          children: [
            const Text(
              'Đánh giá: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Text(
              widget.review.scoreName,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Row list of images
        if (widget.review.images.isNotEmpty)
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.review.images.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context) => ImageCarouselPage(
                            images: widget.review.images,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: widget.review.images[index],
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        const Divider(
          thickness: 1.5,
          height: 60,
        ),
      ],
    );
  }
}
