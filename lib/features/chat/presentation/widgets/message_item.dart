import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_reactions/widgets/stacked_reactions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vievu/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vievu/core/utils/display_modal.dart';
import 'package:vievu/core/utils/open_url.dart';
import 'package:vievu/core/utils/show_snackbar.dart';
import 'package:vievu/features/chat/domain/entities/message.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/features/chat/presentation/widgets/add_place_by_name_modal.dart';
import 'package:vievu/features/chat/presentation/widgets/highlight_location_details_modal.dart';
import 'package:vievu/features/chat/presentation/widgets/reaction_modal.dart';

class MessageItem extends StatefulWidget {
  final Message message;
  final bool highlight;
  const MessageItem({
    super.key,
    required this.message,
    this.highlight = false,
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

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Row(
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
                Stack(children: [
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: widget.message.reactions.isEmpty ? 0 : 14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!_isMe)
                          Text(
                            widget.message.user.firstName,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        if (isEmojiOnly)
                          Text(
                            widget.message.content,
                            style: const TextStyle(fontSize: 40),
                          )
                        else
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: constraints.maxWidth * 2 / 3,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: !widget.highlight
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                    : Theme.of(context)
                                        .colorScheme
                                        .tertiaryContainer,
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
                                    widget.message.content,
                                    widget.message.metaData ?? [],
                                    widget.message,
                                    context),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: !_isMe ? 0 : null,
                    left: _isMe ? 0 : null,
                    child: GestureDetector(
                      onTap: () {
                        displayModal(
                            context,
                            ReactionsModal(message: widget.message),
                            400,
                            false);
                      },
                      child: StackedReactions(
                        size: 14,
                        reactions: widget.message.reactions.map(
                          (reaction) {
                            return reaction.reaction;
                          },
                        ).toList(),
                        stackedValue: -5.0,
                      ),
                    ),
                  ),
                ])
              ],
            ),
            if (widget.message.seenUser != null &&
                widget.message.seenUser!.isNotEmpty)
              Column(
                children: [
                  const SizedBox(height: 5),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    ...widget.message.seenUser!
                        .where((e) =>
                            e.id !=
                            (context.read<AppUserCubit>().state
                                    as AppUserLoggedIn)
                                .user
                                .id)
                        .map((user) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 2.0),
                        child: CircleAvatar(
                          radius: 8,
                          backgroundImage:
                              CachedNetworkImageProvider(user.avatarUrl ?? ""),
                        ),
                      );
                    }),
                    const SizedBox(width: 5),
                  ]),
                ],
              ),
          ],
        );
      },
    );
  }
}

TextSpan _buildHighlightedText(
  String text,
  List<Map<String, dynamic>> metaData,
  Message message,
  BuildContext context,
) {
  const String retractedMessageText = "Tin nhắn đã bị gỡ";
  if (text == retractedMessageText) {
    return TextSpan(
      text: retractedMessageText,
      style: TextStyle(
        fontSize: 16,
        fontFamily: GoogleFonts.merriweather().fontFamily,
        color: Colors.grey,
        fontStyle: FontStyle.italic,
        height: 1.2,
      ),
    );
  }

  List<InlineSpan> spans = [];
  int start = 0;

  final highlights = metaData.map((item) => item['title'] as String).toList();
  // Sắp xếp để ưu tiên khớp với chuỗi dài hơn trước
  highlights.sort((a, b) => b.length.compareTo(a.length));

  final urlRegex = RegExp(r'(https?:\/\/[^\s]+)', caseSensitive: false);

  final defaultTextStyle = TextStyle(
    fontSize: 16,
    fontFamily: GoogleFonts.merriweather().fontFamily,
    color: Theme.of(context).colorScheme.onSurface,
    height: 1.2,
  );

  final linkTextStyle = TextStyle(
    decoration: TextDecoration.underline,
    decorationColor: Colors.blue,
    color: Colors.blue,
    fontFamily: GoogleFonts.merriweather().fontFamily,
    fontSize: 16,
    height: 1.2,
  );

  final highlightTextStyle = TextStyle(
    fontFamily: GoogleFonts.merriweather().fontFamily,
    fontSize: 16,
    height: 1.2,
    fontWeight: FontWeight.bold,
    color: Theme.of(context).colorScheme.primary,
  );

  while (start < text.length) {
    int? highlightResultStartInSubstring;
    String? matchedHighlightText;
    int? linkResultStartInSubstring;
    RegExpMatch? matchedLinkRegexMatch;

    String remainingText = text.substring(start);

    // Tìm link đầu tiên trong phần còn lại của text
    final firstLinkMatch = urlRegex.firstMatch(remainingText);
    if (firstLinkMatch != null) {
      linkResultStartInSubstring = firstLinkMatch.start;
      matchedLinkRegexMatch = firstLinkMatch;
    }

    // Tìm highlight đầu tiên trong phần còn lại của text
    for (var highlightCandidate in highlights) {
      final index = remainingText.indexOf(highlightCandidate);
      if (index != -1 &&
          (highlightResultStartInSubstring == null ||
              index < highlightResultStartInSubstring)) {
        highlightResultStartInSubstring = index;
        matchedHighlightText = highlightCandidate;
      }
    }

    if (highlightResultStartInSubstring != null &&
        (linkResultStartInSubstring == null ||
            highlightResultStartInSubstring < linkResultStartInSubstring)) {
      // Highlight xuất hiện trước link
      int actualHighlightStart = start + highlightResultStartInSubstring;
      if (actualHighlightStart > start) {
        spans.add(TextSpan(
          text: text.substring(start, actualHighlightStart),
          style: defaultTextStyle,
        ));
      }
      final matchedItem =
          metaData.firstWhere((e) => e['title'] == matchedHighlightText);
      spans.add(TextSpan(
        text: matchedHighlightText!,
        style: highlightTextStyle,
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            if (matchedItem['type'] == 'address') {
              String googleMapsUrl =
                  "https://www.google.com/maps/search/?api=1&query=${matchedHighlightText!}";
              openDeepLink(googleMapsUrl);
            } else if (matchedItem['id'] != null) {
              displayModal(
                context,
                HighlightLocationDetailsModal(locationDetails: matchedItem),
                null,
                false,
              );
            } else {
              final userId =
                  (context.read<AppUserCubit>().state as AppUserLoggedIn)
                      .user
                      .id;
              if (userId != message.user.id) {
                showSnackbar(
                    context, "Chưa có thông tin chi tiết cho địa điểm này");
                return;
              }
              displayModal(
                context,
                AddPlaceByNameModal(
                  searchKey: matchedHighlightText!,
                  message: message,
                ),
                null,
                true,
              );
            }
          },
      ));
      start = actualHighlightStart + matchedHighlightText.length;
    } else if (linkResultStartInSubstring != null) {
      // Link xuất hiện trước highlight (hoặc chỉ có link)
      int actualLinkStart = start + linkResultStartInSubstring;
      if (actualLinkStart > start) {
        spans.add(TextSpan(
          text: text.substring(start, actualLinkStart),
          style: defaultTextStyle,
        ));
      }
      final linkText = matchedLinkRegexMatch!.group(0)!;
      spans.add(TextSpan(
        text: linkText,
        style: linkTextStyle,
        recognizer: TapGestureRecognizer()
          ..onTap = () => openDeepLink(linkText),
      ));
      start = actualLinkStart + linkText.length;
    } else {
      // Không còn highlight hay link, thêm phần text còn lại
      spans.add(TextSpan(
        text: text.substring(start),
        style: defaultTextStyle,
      ));
      break;
    }
  }

  return TextSpan(children: spans);
}
