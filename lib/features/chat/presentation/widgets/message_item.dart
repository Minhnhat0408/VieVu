import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
                          "https://plus.unsplash.com/premium_photo-1681426327290-1ec5fb4d3dd8?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8cmVhbGx5JTIwY29vbHxlbnwwfHwwfHx8MA%3D%3D",
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            if (isEmojiOnly)
              Text(
                widget.message.content,
                style: const TextStyle(fontSize: 40), // Larger size for emoji
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
                  child: Text(
                    widget.message.content,
                    style: const TextStyle(fontSize: 16),
                    softWrap: true,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
