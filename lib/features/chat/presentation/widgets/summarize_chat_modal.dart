import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:timelines/timelines.dart';
import 'package:vn_travel_companion/core/utils/conversions.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/features/chat/domain/entities/chat.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:vn_travel_companion/features/chat/presentation/widgets/summary_timeline.dart';
import 'package:vn_travel_companion/features/trips/presentation/pages/trip_detail_page.dart';

class SummarizeChatModal extends StatefulWidget {
  final Chat chat;
  const SummarizeChatModal({
    super.key,
    required this.chat,
  });

  @override
  State<SummarizeChatModal> createState() => _SummarizeChatModalState();
}

class _SummarizeChatModalState extends State<SummarizeChatModal> {
  ChatSummarize? chatSummarize;
  List<bool> _expanded = [];
  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('vi', timeago.ViMessages());
    // chatSummarize = widget.chat.summarizeItineraries;
    context.read<ChatBloc>().add(GetChatSummary(chatId: widget.chat.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        toolbarHeight: 80,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.chat.name,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
              ),
            ),
            Text(
                "Cập nhật lần cuối ${timeago.format(chatSummarize?.createdAt.toLocal() ?? DateTime.now(), locale: 'vi')}",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 14,
                )),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatSummarizedSuccess) {
            chatSummarize = state.chatSummarize;
            if (chatSummarize != null) {
              _expanded = List.generate(chatSummarize!.summary.length, (index) {
                return false;
              });
            }
          }

          if (state is ChatCreateTripItinerarySuccess) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle),
                          const SizedBox(width: 10),
                          Text(
                            'Tạo lịch trình thành công',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                              fontFamily: GoogleFonts.merriweather().fontFamily,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TripDetailPage(
                                        tripId: widget.chat.tripId!,
                                        initialIndex: 2,
                                      )));
                        },
                        child: Text('Xem ngay',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor:
                                  Theme.of(context).colorScheme.onSurface,
                            )),
                      ),
                    ],
                  ),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
          }
        },
        builder: (context, state) {
          return Stack(children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    'Tổng hợp lịch trình từ cuộc trò chuyện',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: state is ChatLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : chatSummarize != null
                          ? SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ExpansionPanelList(
                                      expansionCallback:
                                          (int index, bool isExpanded) {
                                        setState(() {
                                          _expanded[index] = isExpanded;
                                        });
                                      },
                                      expandedHeaderPadding:
                                          const EdgeInsets.all(0),
                                      animationDuration:
                                          const Duration(milliseconds: 1000),
                                      children: [
                                        ...chatSummarize!.summary
                                            .asMap()
                                            .entries
                                            .map((item) {
                                          final panel = item.value;
                                          final index = item.key;
                                          return ExpansionPanel(
                                            headerBuilder:
                                                (BuildContext context,
                                                    bool isExpanded) {
                                              return ListTile(
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 10),
                                                title: Text(panel['day'],
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              );
                                            },

                                            canTapOnHeader: true,

                                            body: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                child: panel['events']
                                                            .isEmpty &&
                                                        _expanded[index]
                                                    ? _emptyItineraryDisplay(
                                                        DateTime.parse(
                                                            panel['day']))
                                                    : _itinerariesDisplay(
                                                        List<
                                                                Map<String,
                                                                    dynamic>>.from(
                                                            panel['events']),
                                                      )),

                                            isExpanded: _expanded[
                                                index], // Use the correct index
                                          );
                                        }),
                                      ]),
                                ],
                              ),
                            )
                          : Center(
                              child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 100,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(height: 10),
                                OutlinedButton(
                                    onPressed: () {
                                      showSnackbar(
                                          context,
                                          'Có thể mất một chút thời gian để tổng hợp lịch trình',
                                          SnackBarState.warning);
                                      context.read<ChatBloc>().add(
                                          SummarizeItineraries(
                                              chatId: widget.chat.id));
                                    },
                                    child: const Text('Tổng hợp ngay')),
                              ],
                            )),
                ),
                Divider(
                  thickness: 1,
                  color: Theme.of(context).colorScheme.primary,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: OutlinedButton(
                          onPressed: () {
                            context.read<ChatBloc>().add(
                                SummarizeItineraries(chatId: widget.chat.id));
                            showSnackbar(
                                context,
                                'Có thể mất một chút thời gian để tổng hợp lịch trình',
                                SnackBarState.warning);
                          },
                          child: const Text(
                            'Tổng hợp',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                    ),
                    BlocBuilder<ChatBloc, ChatState>(
                      builder: (context, state) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: ElevatedButton(
                              onPressed: chatSummarize != null
                                  ? () {
                                      if (chatSummarize!.isConverted) {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Lịch trình đã được tạo'),
                                                content: const Text(
                                                    'Lịch trình đã được tạo từ cuộc trò chuyện này'),
                                                actions: <Widget>[
                                                  FilledButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text('Đóng'),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  OutlinedButton(
                                                    onPressed: () {
                                                      context.read<ChatBloc>().add(
                                                          CreateItineraryFromSummary(
                                                              chatId: widget
                                                                  .chat.id));
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child:
                                                        const Text('Tạo lại'),
                                                  ),
                                                ],
                                              );
                                            });
                                      } else {
                                        context.read<ChatBloc>().add(
                                            CreateItineraryFromSummary(
                                                chatId: widget.chat.id));
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                              ),
                              child: const Text('Tạo lịch trình',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold))),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
            if (state is ChatCreateTripItineraryLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  width: double.infinity,
                  height: double.infinity,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text(
                          'Đang tạo lịch trình...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ]);
        },
      ),
    );
  }

  Widget _itinerariesDisplay(
    List<Map<String, dynamic>> itineraries,
  ) {
    return FixedTimeline.tileBuilder(
      theme: TimelineThemeData(
        nodePosition: 0,
        color: Theme.of(context).colorScheme.outline,
        indicatorTheme: const IndicatorThemeData(
          position: 0,
          size: 20.0,
        ),
        connectorTheme: const ConnectorThemeData(
          thickness: 2.5,
        ),
      ),
      builder: TimelineTileBuilder.connected(
        connectionDirection: ConnectionDirection.before,
        contentsBuilder: (context, index) => SummaryTimeline(
          item: itineraries[index],
        ),
        itemCount: itineraries.length,
        indicatorBuilder: (_, index) {
          return OutlinedDotIndicator(
            size: 36.0,
            borderWidth: 2,
            child: Tooltip(
              message: 'Hello',
              child: convertTypeStringToIcons(
                  itineraries[index]['metaData']['type'], 20),
            ),
          );
        },
        connectorBuilder: (_, index, ___) => const DashedLineConnector(
          gap: 5,
          thickness: 2,
          dash: 1,
        ),
      ),
    );
  }

  Widget _emptyItineraryDisplay(DateTime panel) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 28),
      child: Column(
        children: [
          Text(
            "Chưa có mục nào",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
