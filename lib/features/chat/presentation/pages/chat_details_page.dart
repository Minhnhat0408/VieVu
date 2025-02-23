import 'dart:developer';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/core/layouts/custom_appbar.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/features/chat/domain/entities/chat.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/chat/domain/entities/message.dart';
import 'package:vn_travel_companion/features/chat/presentation/bloc/message_bloc.dart';
import 'package:vn_travel_companion/features/chat/presentation/widgets/message_item.dart';

class ChatDetailsPage extends StatefulWidget {
  final Chat chat;
  const ChatDetailsPage({
    super.key,
    required this.chat,
  });

  @override
  State<ChatDetailsPage> createState() => _ChatDetailsPageState();
}

class _ChatDetailsPageState extends State<ChatDetailsPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isEmojiVisible = false;
  late MessageBloc _messageBloc;
  final List<Message> messages = [];
  int totalRecordCount = 0;
  final PagingController<int, Message> _pagingController =
      PagingController(firstPageKey: 0); // Start at page 0
  final _pageSize = 5;
  @override
  void initState() {
    super.initState();
    _messageBloc = context.read<MessageBloc>(); // Lưu tham chiếu
    _pagingController.addPageRequestListener((pageKey) {
      _messageBloc.add(GetMessagesInChat(
        chatId: widget.chat.id,
        limit: _pageSize,
        offset: pageKey,
      ));
    });
    _messageBloc.add(ListenToMessagesChannel(chatId: widget.chat.id));
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _messageBloc.add(
        UnSubcribeToMessagesChannel(channelName: 'chat:${widget.chat.id}'));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.chevron_left),
                iconSize: 32,
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  Navigator.of(context).pop(); // Navigate back
                },
              )
            : null,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        titleSpacing: 0,
        title: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(widget.chat.imageUrl),
            radius: 20,
          ),
          visualDensity: VisualDensity.compact,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 0.0, vertical: 6),
          title: Text(
            widget.chat.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Online',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Theme.of(context).colorScheme.outline, fontSize: 12),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          BlocConsumer<MessageBloc, MessageState>(
            listener: (context, state) {
              // TODO: implement listener
              if (state is MessagesLoadedSuccess) {
                totalRecordCount += state.messages.length;

                log("Total record count: $totalRecordCount");

                final next = totalRecordCount;
                final isLastPage = state.messages.length < _pageSize;
                if (isLastPage) {
                  _pagingController.appendLastPage(state.messages);
                } else {
                  _pagingController.appendPage(state.messages, next);
                }
                log('Messages loaded successfully');
              }

              if (state is MessageInsertSuccess) {
                // add message to first index of list

                if (_pagingController.itemList != null) {
                  _pagingController.itemList = [
                    state.message, // Tin nhắn mới
                    ..._pagingController.itemList!,
                  ];
                }
                totalRecordCount++;
              }

              if (state is MessageFailure) {
                // Show snackbar
                showSnackbar(context, state.message, SnackBarState.error);
              }
            },
            builder: (context, state) {
              return Expanded(
                child: PagedListView<int, Message>(
                  reverse: true, // Show latest messages at the bottom
                  pagingController: _pagingController,

                  builderDelegate: PagedChildBuilderDelegate<Message>(
                    itemBuilder: (context, message, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: MessageItem(
                          key: Key(message.id.toString()), message: message),
                    ),
                    firstPageProgressIndicatorBuilder: (context) =>
                        const Center(child: CircularProgressIndicator()),
                    animateTransitions: true,
                    newPageProgressIndicatorBuilder: (context) =>
                        const Center(child: CircularProgressIndicator()),
                    noItemsFoundIndicatorBuilder: (context) => Column(
                      children: [
                        const SizedBox(height: 200),
                        Icon(
                          Icons.folder_open,
                          size: 100,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No messages',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.image_outlined,
                    )),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            maxLines: 3,
                            minLines: 1,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              hintText: 'Type a message',
                              contentPadding:
                                  const EdgeInsets.fromLTRB(20, 8, 2, 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.emoji_emotions),
                          onPressed: () {
                            setState(
                              () {
                                _isEmojiVisible = !_isEmojiVisible;
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final message = _messageController.text;

                    if (message.isNotEmpty) {
                      context.read<MessageBloc>().add(
                            InsertMessage(
                              message: message,
                              chatId: widget.chat.id,
                            ),
                          );
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
          Offstage(
            offstage: !_isEmojiVisible,
            child: EmojiPicker(
              textEditingController: _messageController,
              scrollController: _scrollController,
              onBackspacePressed: () {
                final text = _messageController.text;
                if (text.isNotEmpty) {
                  _messageController.text = text.substring(0, text.length - 1);
                }
              },
              config: Config(
                height: 256,
                checkPlatformCompatibility: true,
                viewOrderConfig: const ViewOrderConfig(),
                emojiViewConfig: EmojiViewConfig(
                  // Issue: https://github.com/flutter/flutter/issues/28894
                  emojiSizeMax: 28 *
                      (foundation.defaultTargetPlatform == TargetPlatform.iOS
                          ? 1.2
                          : 1.0),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                ),
                skinToneConfig: const SkinToneConfig(),
                categoryViewConfig: CategoryViewConfig(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                ),
                bottomActionBarConfig: BottomActionBarConfig(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                ),
                searchViewConfig: SearchViewConfig(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  buttonIconColor: Theme.of(context).colorScheme.outline,
                  inputTextStyle: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.outline),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
