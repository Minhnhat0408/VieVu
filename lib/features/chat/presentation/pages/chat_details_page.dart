import 'dart:developer';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_reactions/flutter_chat_reactions.dart';
import 'package:flutter_chat_reactions/model/menu_item.dart';
import 'package:flutter_chat_reactions/utilities/hero_dialog_route.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/core/utils/display_modal.dart';
import 'package:vn_travel_companion/core/utils/onboarding_help.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/features/auth/domain/entities/user.dart';
import 'package:vn_travel_companion/features/chat/data/models/message_model.dart';
import 'package:vn_travel_companion/features/chat/domain/entities/chat.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/chat/domain/entities/message.dart';
import 'package:vn_travel_companion/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:vn_travel_companion/features/chat/presentation/bloc/message_bloc.dart';
import 'package:vn_travel_companion/features/chat/presentation/widgets/chat_input.dart';
import 'package:vn_travel_companion/features/chat/presentation/widgets/message_item.dart';
import 'package:vn_travel_companion/features/chat/presentation/widgets/summarize_chat_modal.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/trip_detail_page.dart';
import 'package:timeago/timeago.dart' as timeago;

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
  late MessageBloc _messageBloc;
  late ChatBloc _chatBloc;
  final List<Message> messages = [];
  bool _isOverlayVisible = false;

  void _toggleOverlay(bool isVisible) {
    setState(() {
      _isOverlayVisible = isVisible;
    });
  }

  int totalRecordCount = 0;
  final PagingController<int, Message> _pagingController =
      PagingController(firstPageKey: 0); // Start at page 0
  final _pageSize = 5;
  List<Map<int, User>> seenUser = [];

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('vi', timeago.ViMessages());

    _messageBloc = context.read<MessageBloc>(); // Lưu tham chiếu
    _chatBloc = context.read<ChatBloc>();
    _pagingController.addPageRequestListener((pageKey) {
      _messageBloc.add(GetMessagesInChat(
        chatId: widget.chat.id,
        limit: _pageSize,
        offset: pageKey,
      ));
    });
    _messageBloc.add(ListenToMessageReactionChannel(chatId: widget.chat.id));
    _chatBloc.add(GetSeenUser(chatId: widget.chat.id));
    _messageBloc.add(ListenToMessagesChannel(chatId: widget.chat.id));
    _messageBloc.add(ListenToMessageUpdateChannel(chatId: widget.chat.id));
    _chatBloc.add(ListenToChatMembersChannel(chatId: widget.chat.id));
  }

  @override
  void dispose() {
    _pagingController.dispose();
    // _chatBloc.add(UnSubcribeToSeenUserChannel(chatId: widget.chat.id));
    _chatBloc.add(UnSubcribeToChatMembersChannel(
        channelName: 'chat_members:${widget.chat.id}'));
    _messageBloc.add(UnSubcribeToMessagesChannel(
        channelName: 'chat_insert:${widget.chat.id}'));
    _messageBloc.add(UnSubcribeToMessagesChannel(
        channelName: 'chat_update:${widget.chat.id}'));
    _messageBloc.add(UnSubcribeToMessagesChannel(
        channelName: 'message_reactions:${widget.chat.id}'));
    super.dispose();
  }

  void addReactionToMessage({
    required Message message,
    required MessageReaction reaction,
  }) {
    if (message.reactions.any((element) =>
        element.reaction == reaction.reaction &&
        element.user.id == reaction.user.id)) {
      message.reactions
          .removeWhere((element) => element.user.id == reaction.user.id);
      context.read<MessageBloc>().add(RemoveReaction(
            messageId: message.id,
          ));
    } else {
      message.reactions
          .removeWhere((element) => element.user.id == reaction.user.id);
      message.reactions.add(reaction);
      context.read<MessageBloc>().add(InsertReaction(
            messageId: message.id,
            chatId: widget.chat.id,
            reaction: reaction.reaction,
          ));
    }

    setState(() {});
  }

  void showEmojiBottomSheet({
    required Message message,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return EmojiPicker(
          onEmojiSelected: ((category, emoji) {
            // pop the bottom sheet
            Navigator.pop(context);
            addReactionToMessage(
              message: message,
              reaction: MessageReactionModel(
                id: 0,
                messageId: message.id,
                user: (context.read<AppUserCubit>().state as AppUserLoggedIn)
                    .user,
                reaction: emoji.emoji,
              ),
            );
          }),
          config: Config(
            height: 256,
            checkPlatformCompatibility: true,
            viewOrderConfig: const ViewOrderConfig(),
            emojiViewConfig: EmojiViewConfig(
              emojiSizeMax: 28,
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
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _toggleOverlay(false);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(Icons.chevron_left),
                  iconSize: 32,
                  padding: const EdgeInsets.all(0),
                  onPressed: () {
                    if (_isOverlayVisible) {
                      _toggleOverlay(false);
                    } else {
                      Navigator.of(context).pop(); // Navigate back
                    }
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
              widget.chat.lastMessageTime != null
                  ? "Online ${timeago.format(widget.chat.lastMessageTime!, locale: 'vi')}"
                  : "Offline",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.outline, fontSize: 12),
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  displayModal(
                      context,
                      SummarizeChatModal(
                        chat: widget.chat,
                      ),
                      null,
                      true);
                },
                icon: Icon(
                  Icons.document_scanner,
                  color: Theme.of(context).colorScheme.primary,
                )),
            PopupMenuButton(
              onSelected: (item) {
                if (item == "itinerary") {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TripDetailPage(
                                tripId: widget.chat.tripId!,
                                initialIndex: 2,
                              )));
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                const PopupMenuItem(
                    value: "itinerary",
                    child: ListTile(
                      leading: Icon(Icons.card_travel),
                      title: Text('Xem lịch trình'),
                    )),
                const PopupMenuItem(
                    value: "h2",
                    child: ListTile(
                      leading: Icon(Icons.delete),
                      title: Text('Xóa cuộc trò chuyện'),
                    )),
                const PopupMenuItem(
                    value: "leave",
                    child: ListTile(
                      leading: Icon(Icons.output),
                      title: Text('Thoát khỏi nhóm'),
                    )),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                // TODO: implement listener
                if (state is SeenUpdatedSuccess) {
                  setState(() {
                    seenUser = state.seenUser;
                  });
                }
              },
              builder: (context, state) {
                return BlocConsumer<MessageBloc, MessageState>(
                  listener: (context, state) {
                    // TODO: implement listener
                    if (state is MessagesLoadedSuccess) {
                      if (widget.chat.isSeen == false &&
                          totalRecordCount == 0) {
                        _messageBloc.add(UpdateSeenMessage(
                          chatId: widget.chat.id,
                          messageId: state.messages.first.id,
                        ));
                      }
                      totalRecordCount += state.messages.length;

                      final next = totalRecordCount;
                      final isLastPage = state.messages.length < _pageSize;
                      if (isLastPage) {
                        _pagingController.appendLastPage(state.messages);
                      } else {
                        _pagingController.appendPage(state.messages, next);
                      }
                    }

                    if (state is MessageReactionSuccess) {
                      // add reaction to message
                      if (state.eventType == "insert") {
                        final messageIndex = _pagingController.itemList!
                            .indexWhere((element) =>
                                element.id == state.reaction!.messageId);

                        if (messageIndex != -1) {
                          final updatedList = _pagingController.itemList!;
                          updatedList[messageIndex]
                              .reactions
                              .add(state.reaction!);
                          setState(() {
                            _pagingController.itemList = updatedList;
                          });
                        }
                      } else if (state.eventType == "delete") {
                        final messageIndex = _pagingController.itemList!
                            .indexWhere((element) => element.reactions.any(
                                (element) => element.id == state.reactionId));

                        if (messageIndex != -1) {
                          final updatedList = _pagingController.itemList!;
                          updatedList[messageIndex].reactions.removeWhere(
                              (element) => element.id == state.reactionId);
                          setState(() {
                            _pagingController.itemList = updatedList;
                          });
                        }
                      } else {
                        final messageIndex = _pagingController.itemList!
                            .indexWhere((element) =>
                                element.id == state.reaction!.messageId);

                        if (messageIndex != -1) {
                          final updatedList = _pagingController.itemList!;
                          updatedList[messageIndex].reactions.removeWhere(
                              (element) => element.id == state.reaction!.id);
                          updatedList[messageIndex]
                              .reactions
                              .add(state.reaction!);
                          setState(() {
                            _pagingController.itemList = updatedList;
                          });
                        }
                      }
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

                      OnboardingHelper.hasSeenChatGuide()
                          .then((hasSeenChatGuide) {
                        if (!hasSeenChatGuide) {
                          // Hiển thị thông báo hướng dẫn
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Hướng dẫn"),
                              content: const Text(
                                  "Tên địa điểm sẽ được tự động highlight trong tin nhắn của bạn. Hãy bấm vào phần highlight để thêm thông tin chi tiết cho địa điểm."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Đã hiểu"),
                                ),
                              ],
                            ),
                          );

                          // Đánh dấu là đã xem hướng dẫn
                          OnboardingHelper.setSeenChatGuide();
                        }
                      });
                    }

                    if (state is MessageUpdateSuccess) {
                      // add message to first index of list
                      final messageIndex = _pagingController.itemList!
                          .indexWhere(
                              (element) => element.id == state.message.id);

                      if (messageIndex != -1) {
                        final updatedList = _pagingController.itemList!;
                        updatedList[messageIndex] = state.message;
                        setState(() {
                          _pagingController.itemList = updatedList;
                        });
                      }
                    }

                    if (state is MessageUpdateReceivedSuccess) {
                      // add message to first index of list
                      final messageIndex = _pagingController.itemList!
                          .indexWhere(
                              (element) => element.id == state.message['id']);

                      if (messageIndex != -1) {
                        final updatedList = _pagingController.itemList!;
                        updatedList[messageIndex].metaData =
                            (state.message['meta_data'] as List)
                                .map((e) => Map<String, dynamic>.from(e))
                                .toList();
                        updatedList[messageIndex].content =
                            state.message['content'];
                        setState(() {
                          _pagingController.itemList = updatedList;
                        });
                      }
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
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        builderDelegate: PagedChildBuilderDelegate<Message>(
                          itemBuilder: (context, message, index) {
                            // fillter out seen user
                            final seenUserList = seenUser
                                .where((element) =>
                                    element.keys.first == message.id)
                                .toList();
                            if (seenUserList.isNotEmpty) {
                              message.seenUser = seenUserList
                                  .map((e) => e.values.first)
                                  .toList();
                            } else {
                              message.seenUser = null;
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: GestureDetector(
                                onLongPress: () {
                                  OnboardingHelper.hasSeenReactionGuide()
                                      .then((hasSeen) {
                                    if (!hasSeen) {
                                      // Hiển thị thông báo hướng dẫn
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("Hướng dẫn"),
                                          content: const Text(
                                              "Lựa chọn 👍👎 sẽ có tính vote quyết định ý kiến. Ý kiến được vote 👍 sẽ được tính trong việc tổng hợp lịch trình"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("Đã hiểu"),
                                            ),
                                          ],
                                        ),
                                      );


                                      OnboardingHelper.setSeenReactionGuide();
                                    }
                                  });
                                  Navigator.of(context).push(
                                    HeroDialogRoute(
                                      builder: (context) {
                                        return ReactionsDialogWidget(
                                          id: message.id
                                              .toString(), // unique id for message
                                          messageWidget: MessageItem(
                                            // key: Key(message.id.toString()),
                                            message: message,
                                          ),
                                          reactions: const [
                                            '❤️',
                                            '👍',
                                            '👎',
                                            '😩',
                                            '😢',
                                            '😂',
                                            '➕'
                                          ],
                                          onReactionTap: (reaction) {
                                            if (reaction == '➕') {
                                              showEmojiBottomSheet(
                                                message: message,
                                              );
                                              return;
                                            }
                                            final user = (context
                                                    .read<AppUserCubit>()
                                                    .state as AppUserLoggedIn)
                                                .user;

                                            addReactionToMessage(
                                              message: message,
                                              reaction: MessageReactionModel(
                                                  id: 0,
                                                  messageId: message.id,
                                                  user: user,
                                                  reaction: reaction),
                                            );
                                          },

                                          onContextMenuTap: (menuItem) {
                                            if (menuItem.label == "Sao chép") {
                                              Clipboard.setData(ClipboardData(
                                                  text: message.content));
                                            } else if (menuItem.label ==
                                                "Gỡ tin nhắn") {
                                              context.read<MessageBloc>().add(
                                                  RemoveMessage(
                                                      messageId: message.id));
                                            }
                                          },
                                          menuItems: const [
                                            MenuItem(
                                              label: "Sao chép",
                                              icon: Icons.copy,
                                            ),
                                            MenuItem(
                                              label: "Gỡ tin nhắn",
                                              icon: Icons.delete,
                                              isDestuctive: true,
                                            ),
                                          ],
                                          widgetAlignment: message.user.id ==
                                                  (context
                                                              .read<AppUserCubit>()
                                                              .state
                                                          as AppUserLoggedIn)
                                                      .user
                                                      .id
                                              ? Alignment.centerRight
                                              : Alignment.centerLeft,
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Hero(
                                  tag: message.id,
                                  child: MessageItem(
                                      key: Key(message.id.toString()),
                                      message: message),
                                ),
                              ),
                            );
                          },
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
                );
              },
            ),
            ChatInput(
              chat: widget.chat,
              onOverlayToggle: _toggleOverlay,
              isOverlayVisible: _isOverlayVisible,
            ),
          ],
        ),
      ),
    );
  }
}
