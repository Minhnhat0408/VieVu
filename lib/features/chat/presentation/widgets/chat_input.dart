import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/core/utils/custom_text_editing_controller.dart';
import 'package:vievu/core/utils/display_modal.dart';
import 'package:vievu/core/utils/onboarding_help.dart';
import 'package:vievu/core/utils/overlay_button_builder.dart';
import 'package:vievu/features/chat/domain/entities/chat.dart';
import 'package:vievu/features/chat/presentation/bloc/message_bloc.dart';
import 'package:vievu/features/search/domain/entities/explore_search_result.dart';
import 'package:vievu/features/search/presentation/bloc/search_bloc.dart';

class ChatInput extends StatefulWidget {
  final Chat chat;
  final Function(bool) onOverlayToggle;
  final bool isOverlayVisible;
  const ChatInput({
    super.key,
    required this.chat,
    required this.onOverlayToggle,
    required this.isOverlayVisible,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  late CustomTextEditingController _messageController;
  final FocusNode _messageFocusNode = FocusNode();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  String previousText = '';
  late FocusNode _focusNode;
  void _onSearchChanged(String keyword) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      context.read<SearchBloc>().add(SearchAllLocal(
            searchText: keyword,
            limit: 5,
            offset: 0,
            tripId: widget.chat.tripId,
          ));
    });
  }

  final List<ExploreSearchResult> _searchResults = [];
  @override
  void dispose() {
    _messageController.dispose();

    _scrollController.dispose();
    _debounce?.cancel();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _messageController = CustomTextEditingController();
    // _messageController.addListener(_handleTextChange);
    _focusNode = FocusNode();

    // Listen to focus changes
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        // On focus, set the cursor to the end of the text
        _messageController.selection = TextSelection.collapsed(
          offset: _messageController.text.length + 1,
        );
      }
    });
    // _messageController.;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      OverlayButtonBuilder(
        showOverlay: widget.isOverlayVisible,
        anchor: const OverlayAnchor(
          button: Alignment.topCenter,
          dialog: Alignment.bottomCenter,
        ),
        overlay: _buildLocationSearch(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  if (!widget.isOverlayVisible) {
                    widget.onOverlayToggle(true);
                  } else {
                    widget.onOverlayToggle(false);
                  }
                  _searchFocusNode.requestFocus();
                  // OnboardingHelper.resetSeenTagGuide();
                  OnboardingHelper.hasSeenTagGuide().then((value) {
                    if (!value) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Hướng dẫn'),
                          content: const Text(
                              'Tra và chọn địa điểm bạn muốn chia sẻ để thêm vào tin nhắn. Đia điểm sẽ được highlight và bạn có thể nhấn vào để xem chi tiết.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Đã hiểu'),
                            ),
                          ],
                        ),
                      );
                    }
                  });

                  OnboardingHelper.setSeenTagGuide();
                },
                icon: const Icon(Icons.add_location_sharp),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          onTapOutside: (event) => _messageFocusNode.unfocus(),
                          focusNode: _messageFocusNode,
                          controller: _messageController,
                          maxLines: 3,
                          minLines: 1,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            hintText: 'Nhập tin nhắn',
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
                          // showTopDialog(context);
                          displayModal(
                              context,
                              EmojiPicker(
                                textEditingController: _messageController,
                                scrollController: _scrollController,
                                onBackspacePressed: () {
                                  final text = _messageController.text;
                                  if (text.isNotEmpty) {
                                    _messageController.text =
                                        text.substring(0, text.length - 1);
                                  }
                                },
                                config: Config(
                                  height: 256,
                                  checkPlatformCompatibility: true,
                                  viewOrderConfig: const ViewOrderConfig(),
                                  emojiViewConfig: EmojiViewConfig(
                                    emojiSizeMax: 28 *
                                        (defaultTargetPlatform ==
                                                TargetPlatform.iOS
                                            ? 1.2
                                            : 1.0),
                                    backgroundColor:
                                        Theme.of(context).colorScheme.surface,
                                  ),
                                  skinToneConfig: const SkinToneConfig(),
                                  categoryViewConfig: CategoryViewConfig(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.surface,
                                  ),
                                  bottomActionBarConfig: BottomActionBarConfig(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.surface,
                                  ),
                                  searchViewConfig: SearchViewConfig(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.surface,
                                    buttonIconColor:
                                        Theme.of(context).colorScheme.outline,
                                    inputTextStyle: TextStyle(
                                      fontSize: 18,
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                ),
                              ),
                              null,
                              false);
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
                            chatMemberId: widget.chat.chatMemberId,
                            chatId: widget.chat.id,
                            metaData:
                                _messageController.searchResults.isNotEmpty
                                    ? _messageController.searchResults
                                        .where((element) =>
                                            message.contains(element.title))
                                        .map((e) => e.toMap())
                                        .toList()
                                    : null,
                          ),
                        );
                    _messageController.clear();
                    _messageController.searchResults.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  Widget _buildLocationSearch() {
    return BlocConsumer<SearchBloc, SearchState>(
      listener: (context, state) {
        if (state is SearchSuccess) {
          setState(() {
            _searchResults.clear();
            _searchResults.addAll(state.results);
          });
        }
      },
      builder: (context, state) {
        return Container(
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                focusNode: _searchFocusNode,
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Nhập để tìm địa điểm',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: state is SearchLoading
                      ? Container(
                          width: 30,
                          alignment: Alignment.center,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : null,
                ),
                onChanged: (value) {
                  if (value.trim().isNotEmpty) _onSearchChanged(value);
                },
              ),
              if (_searchResults.isNotEmpty)
                Column(
                  children: _searchResults
                      .map((result) => ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: CachedNetworkImage(
                                width: 40,
                                height: 40,
                                imageUrl: result.cover ?? '',
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  'assets/images/trip_placeholder.webp', // Fallback if loading fails
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            trailing: Icon(
                              result.isSaved
                                  ? Icons.favorite
                                  : Icons.favorite_outline,
                              color: result.isSaved ? Colors.redAccent : null,
                            ),
                            title: Text(result.title),
                            onTap: () {
                              _messageController.text =
                                  "${_messageController.text}${result.title}";

                              // check for no duplicate
                              _messageController.searchResults.contains(result)
                                  ? null
                                  : _messageController.searchResults
                                      .add(result);

                              _messageFocusNode.requestFocus();
                              widget.onOverlayToggle(false);
                            },
                          ))
                      .toList(),
                )
            ],
          ),
        );
      },
    );
  }
}
