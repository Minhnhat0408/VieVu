import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vn_travel_companion/core/utils/display_modal.dart';
import 'package:vn_travel_companion/features/chat/domain/entities/chat.dart';
import 'package:vn_travel_companion/features/chat/presentation/pages/chat_details_page.dart';

class ChatHeadItem extends StatefulWidget {
  final Chat chat;
  final Function onMessageSeen;
  const ChatHeadItem({
    super.key,
    required this.onMessageSeen,
    required this.chat,
  });

  @override
  State<ChatHeadItem> createState() => _ChatHeadItemState();
}

class _ChatHeadItemState extends State<ChatHeadItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        displayFullScreenModal(
            context,
            ChatDetailsPage(
              chat: widget.chat,
            )).then((value) {
          widget.onMessageSeen();
        });
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(widget.chat.imageUrl),
          radius: 30,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Text(
            widget.chat.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                widget.chat.lastMessage ?? 'Không có tin nhắn',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            Text(
                widget.chat.lastMessageTime != null
                    ? DateFormat('HH:mm')
                        .format(widget.chat.lastMessageTime!.toLocal())
                    : DateFormat('HH:mm').format(DateTime.now()),
                style: TextStyle(color: Theme.of(context).colorScheme.outline)),
          ],
        ),
        trailing: widget.chat.isSeen
            ? widget.chat.lastSeenUserAvatar != null
                ? CircleAvatar(
                    radius: 8,
                    backgroundImage: CachedNetworkImageProvider(
                      widget.chat.lastSeenUserAvatar!,
                    ),
                  )
                : const SizedBox()
            : Container(
                height: 16,
                width: 16   ,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
      ),
    );
  }
}
