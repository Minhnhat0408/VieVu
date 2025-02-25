import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/features/chat/domain/entities/message.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessageItem extends StatefulWidget {
  final Message message;
  const MessageItem({
    super.key,
    required this.message,
  });

  @override
  State<MessageItem> createState() => _MessageItemState();
}

class _MessageItemState extends State<MessageItem> {
  bool _isMe = false;
  @override
  void initState() {
    super.initState();
    final userId =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
    _isMe = widget.message.user.id == userId;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool isEmojiOnly =
        RegExp(r'^[\p{Emoji_Presentation}\p{Emoji}]+$', unicode: true)
            .hasMatch(widget.message.content.trim());

    // Lấy danh sách các tiêu đề từ metadata
    List<String> highlights = (widget.message.metaData ?? [])
        .map((item) => item['title'] as String)
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment:
              _isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!_isMe)
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: CachedNetworkImageProvider(
                      widget.message.user.avatarUrl ??
                          "https://images.viblo.asia/01e51425-fff9-41b3-9f6f-1a24b66ab3d8.jpg",
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_isMe)
                  Text(
                    widget.message.user.firstName,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                if (isEmojiOnly)
                  Text(
                    widget.message.content,
                    style: const TextStyle(
                        fontSize: 40), // Kích thước lớn hơn cho emoji
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * 2 / 3,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(_isMe ? 20 : 0),
                          topRight: Radius.circular(_isMe ? 0 : 20),
                          bottomLeft: const Radius.circular(20),
                          bottomRight: const Radius.circular(20),
                        ),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: RichText(
                        text: _buildHighlightedText(
                            widget.message.content, highlights, context),
                      ),
                    ),
                  ),
              ],
            )
          ],
        );
      },
    );
  }

  TextSpan _buildHighlightedText(
      String text, List<String> highlights, BuildContext context) {
    List<TextSpan> spans = [];
    int start = 0;

    // Sắp xếp danh sách highlights theo độ dài giảm dần để xử lý các tiêu đề lồng nhau
    highlights.sort((a, b) => b.length.compareTo(a.length));

    while (start < text.length) {
      int? highlightStart;
      String? matchedHighlight;

      // Tìm vị trí bắt đầu của highlight gần nhất
      for (var highlight in highlights) {
        final index = text.indexOf(highlight, start);
        if (index != -1 && (highlightStart == null || index < highlightStart)) {
          highlightStart = index;
          matchedHighlight = highlight;
        }
      }

      if (highlightStart != null && matchedHighlight != null) {
        // Thêm phần văn bản trước highlight
        if (start < highlightStart) {
          spans.add(TextSpan(text: text.substring(start, highlightStart)));
        }
        // Thêm phần văn bản được highlight
        spans.add(TextSpan(
          text: matchedHighlight,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ));
        start = highlightStart + matchedHighlight.length;
      } else {
        // Không còn highlight nào, thêm phần còn lại của văn bản
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
    }

    return TextSpan(
        children: spans,
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.onSurface,
          fontFamily: GoogleFonts.merriweather().fontFamily,
        ));
  }
}
