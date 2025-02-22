import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/features/chat/domain/entities/chat.dart';
import 'package:vn_travel_companion/features/chat/domain/entities/message.dart';
import 'package:vn_travel_companion/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:vn_travel_companion/features/chat/presentation/widgets/chat_head_item.dart';

class AllMessagesPage extends StatefulWidget {
  const AllMessagesPage({super.key});

  @override
  State<AllMessagesPage> createState() => _AllMessagesPageState();
}

class _AllMessagesPageState extends State<AllMessagesPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Chat> chats = [];
  @override
  void initState() {
    super.initState();
    final userId =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
    context.read<ChatBloc>().add(GetChatHeads(
          userId: userId,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title: const Text('All Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigator.of(context).pushNamed('/new-message');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: SearchBar(
              controller: _searchController,
              elevation: const WidgetStatePropertyAll(0),
              leading: const Icon(Icons.search),
              onSubmitted: (value) {},
              onChanged: (value) {
                setState(() {});
              },
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
              if (state is ChatsLoadedSuccess) {
                setState(() {
                  chats = state.chatHeads;
                });
              }
              if (state is ChatFailure) {
                showSnackbar(context, state.message, SnackBarState.error);
              }
            },
            builder: (context, state) {
              return state is ChatLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : chats.isNotEmpty
                      ? Expanded(
                          // <-- Thêm Expanded ở đây
                          child: ListView.builder(
                            itemCount: chats.length,
                            itemBuilder: (context, index) {
                              return ChatHeadItem(chat: chats[index]);
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
    );
  }
}
