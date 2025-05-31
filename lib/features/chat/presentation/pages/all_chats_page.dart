
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vievu/features/chat/domain/entities/chat.dart';
import 'package:vievu/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:vievu/features/chat/presentation/widgets/chat_head_item.dart';
import 'package:vievu/features/trips/presentation/bloc/trip_member/trip_member_bloc.dart';

class AllMessagesPage extends StatefulWidget {
  const AllMessagesPage({super.key});

  @override
  State<AllMessagesPage> createState() => _AllMessagesPageState();
}

class _AllMessagesPageState extends State<AllMessagesPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Chat> chats = [];
  List<Chat> filteredChats = [];
  bool _listentoNotification = true;
  @override
  void initState() {
    super.initState();

    context.read<ChatBloc>().add(GetChatHeads());

    _searchController.addListener(() {
      setState(() {
        filteredChats = chats
            .where((element) => element.name
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList();
      });
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liên hệ'),
        actions: [
          Switch(
            value: _listentoNotification,
            thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                (Set<WidgetState> states) {
              return const Icon(Icons.notifications_active_outlined);
            }),
            onChanged: (value) {
              setState(() {
                _listentoNotification = value;
              });
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: BlocListener<TripMemberBloc, TripMemberState>(
        listener: (context, state) {
          if (state is TripMemberDeletedSuccess) {
            final userId =
                (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
            if (state.tripMemberId == userId) {
              context.read<ChatBloc>().add(GetChatHeads());
            }
          }
        },
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<ChatBloc>().add(GetChatHeads());
          },
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                child: SearchBar(
                  controller: _searchController,
                  elevation: const WidgetStatePropertyAll(0),
                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                  leading: const Icon(Icons.search),
                  trailing: _searchController.text.isEmpty
                      ? null
                      : [
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        ],
                  hintText: 'Tìm kiếm liên hệ',
                  padding: const WidgetStatePropertyAll<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 16)),
                ),
              ),
              // Wrap the BlocConsumer with Expanded
              Expanded(
                child: BlocConsumer<ChatBloc, ChatState>(
                  listener: (context, state) {
                    if (state is ChatsLoadedSuccess) {
                      setState(() {
                        chats = state.chatHeads;
                        // Apply search filter immediately
                        if (_searchController.text.isEmpty) {
                          filteredChats = state.chatHeads;
                        } else {
                          filteredChats = chats
                              .where((element) => element.name
                                  .toLowerCase()
                                  .contains(_searchController.text.toLowerCase()))
                              .toList();
                        }
                      });
                    }

                    if (state is ChatInsertSuccess) {
                      setState(() {
                        // Ensure the chat is not already present by ID, then add or update
                        final existingChatIndex = chats.indexWhere((c) => c.id == state.chat.id);
                        if (existingChatIndex != -1) {
                          chats[existingChatIndex] = state.chat; // Update existing
                        } else {
                          chats.insert(0, state.chat); // Add new to the beginning
                        }
                        // Re-apply filter
                        if (_searchController.text.isEmpty) {
                          filteredChats = List.from(chats);
                        } else {
                          filteredChats = chats
                              .where((element) => element.name
                                  .toLowerCase()
                                  .contains(_searchController.text.toLowerCase()))
                              .toList();
                        }
                      });
                    }
                  },
                  builder: (context, state) {
                    if (state is ChatLoading && filteredChats.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (filteredChats.isNotEmpty) {
                      // No need for another Expanded here if BlocConsumer is already Expanded
                      return ListView.builder(
                        itemCount: filteredChats.length,
                        itemBuilder: (context, index) {
                          return ChatHeadItem(
                            chat: filteredChats[index],
                            onMessageSeen: () {
                               // Update isSeen for both lists if the item exists
                              final chatInMasterList = chats.firstWhere((c) => c.id == filteredChats[index].id, orElse: () => filteredChats[index] /* Should not happen if lists are in sync */);
                              setState(() {
                                chatInMasterList.isSeen = true;
                                if (filteredChats[index].id == chatInMasterList.id) {
                                   filteredChats[index].isSeen = true;
                                }
                              });
                            },
                          );
                        },
                      );
                    } else {
                      // Empty state
                      return LayoutBuilder(
                        builder: (BuildContext context,
                            BoxConstraints constraints) {
                          // constraints.maxHeight here will be finite because BlocConsumer is Expanded
                          return SingleChildScrollView(
                            physics:
                                const AlwaysScrollableScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.folder_open,
                                        size: 100,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        'Không có tin nhắn',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // const SizedBox(height: 100), // Consider removing if centering is sufficient
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
