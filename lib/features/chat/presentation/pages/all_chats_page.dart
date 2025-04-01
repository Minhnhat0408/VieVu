import 'dart:developer';

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
    // context.read<ChatBloc>().add(ListenToUpdateChannels());

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
            BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                log(state.toString());
                if (state is ChatsLoadedSuccess) {
                  setState(() {
                    chats = state.chatHeads;
                    filteredChats = state.chatHeads;
                  });
                }

                if (state is ChatInsertSuccess) {
                  setState(() {
                    // add if not exist
                    if (!chats.contains(state.chat)) {
                      chats.add(state.chat);
                    }
                    filteredChats = chats;
                  });
                }
              },
              builder: (context, state) {
                return state is ChatLoading && filteredChats.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : filteredChats.isNotEmpty
                        ? Expanded(
                            // <-- Thêm Expanded ở đây
                            child: ListView.builder(
                              itemCount: filteredChats.length,
                              itemBuilder: (context, index) {
                                return ChatHeadItem(
                                  chat: filteredChats[index],
                                  onMessageSeen: () {
                                    setState(() {
                                      filteredChats[index].isSeen = true;
                                    });
                                  },
                                );
                              },
                            ),
                          )
                        : Column(
                            children: [
                              const SizedBox(height: 200),
                              Icon(
                                Icons.folder_open,
                                size: 100,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Không có tin nhắn',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.outline,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
              },
            ),
          ],
        ),
      ),
    );
  }
}
