import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/comment.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;

  const CommentCard({required this.comment, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
        ),
        padding: const EdgeInsets.all(20),
        clipBehavior: Clip.antiAlias,
        width: 280,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image and Icon
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundImage: NetworkImage(comment.avatar),
                ),
                const SizedBox(width: 8),
                Text(
                  comment.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            AutoSizeText(
              comment.poiName,
              minFontSize: 12, // inimum font size to shrink to
              maxLines: 2, // Allow up to 2 lines for wrapping
              overflow:
                  TextOverflow.ellipsis, // Add ellipsis if it exceeds maxLines
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16, // Default starting font size
              ),
            ),

            const SizedBox(height: 6),
            // Rating
            Text(
              comment.content,
              overflow: TextOverflow.ellipsis,
              maxLines: 8,
            ),
          ],
        ),
      ),
    );
  }
}
