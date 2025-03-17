import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:vn_travel_companion/core/constants/notification_types.dart';
import 'package:vn_travel_companion/core/layouts/custom_appbar.dart';
import 'package:vn_travel_companion/features/auth/presentation/pages/profile_page.dart';
import 'package:vn_travel_companion/features/notifications/domain/entities/notification.dart'
    as app;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:vn_travel_companion/features/trips/presentation/pages/trip_detail_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final PagingController<int, app.Notification> _pagingController =
      PagingController(firstPageKey: 0);
  int totalRecordCount = 0;
  final int pageSize = 10;
  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      context.read<NotificationBloc>().add(
            GetNotifications(limit: pageSize, offset: pageKey),
          );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbar(
      appBarTitle: 'Thông báo',
      centerTitle: true,
      actions: [
        IconButton(
            onPressed: () {
              context
                  .read<NotificationBloc>()
                  .add(MarkAllNotificationsAsRead());
            },
            icon: const Icon(
              Icons.mark_email_read_outlined,
              size: 30,
            ))
      ],
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationLoadedSuccess) {
            totalRecordCount += state.notifications.length;
            // log(state.notifications.toString());
            final next = totalRecordCount;
            final isLastPage = state.notifications.length < pageSize;
            if (isLastPage) {
              _pagingController.appendLastPage(state.notifications);
            } else {
              _pagingController.appendPage(state.notifications, next);
            }
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
              child: PagedListView<int, app.Notification>(
                  pagingController: _pagingController,
                  builderDelegate: PagedChildBuilderDelegate<app.Notification>(
                      itemBuilder: (context, item, index) {
                    return ListTile(
                      onTap: () {
                        if (item.type == NotificationType.rating.type) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ProfilePage(id: item.user!.id)));
                        }
                        if (item.type.contains('trip')) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TripDetailPage(
                                        tripId: item.trip?.id ?? "",
                                        tripCover: item.trip?.cover ?? "",
                                      )));
                        }
                        if (!item.isRead) {
                          context.read<NotificationBloc>().add(
                              MarkNotificationAsRead(notificationId: item.id));
                          // chnag ehte item.isRead to true
                          setState(() {
                            item.isRead = true;
                          });
                        }
                      },
                      leading: Stack(children: [
                        CachedNetworkImage(
                          imageUrl: (item.user != null
                                  ? item.user?.avatarUrl
                                  : item.trip?.cover) ??
                              "",
                          imageBuilder: (context, imageProvider) =>
                              CircleAvatar(
                            radius: 30,
                            backgroundImage: imageProvider,
                          ),
                          height: 60,
                          width: 60,
                          placeholder: (context, url) => const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: NotificationType.allNotificationType
                              .where((element) {
                                return element.type == item.type;
                              })
                              .first
                              .badge,
                        )
                      ]),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      title: RichText(
                        text: TextSpan(
                          children: highlightText(
                              item.type != "trip_update"
                                  ? "${item.user?.firstName ?? ""} ${item.content} ${item.trip?.name ?? ""}"
                                  : "${item.trip?.name ?? ""} ${item.content}",
                              item.content),
                          style: DefaultTextStyle.of(context)
                              .style, // Đảm bảo phong cách văn bản mặc định
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(timeago.format(item.createdAt, locale: 'vi')),
                          if (item.type == "trip_invite" &&
                              item.isAccepted == null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // 2 buttons here delcine and accept

                                ElevatedButton(
                                  onPressed: () {
                                    context.read<NotificationBloc>().add(
                                        RejectTripInvitation(
                                            notificationId: item.id,
                                            tripId: item.trip?.id ?? "",
                                            userId: item.user?.id ?? ""));
                                    setState(() {
                                      item.isAccepted = false;
                                    });
                                  },
                                  child: const Text('Từ chối'),
                                ),

                                FilledButton(
                                  onPressed: () {
                                    context.read<NotificationBloc>().add(
                                        AcceptTripInvitation(
                                            notificationId: item.id,
                                            tripId: item.trip?.id ?? "",
                                            userId: item.user?.id ?? ""));
                                    setState(() {
                                      item.isAccepted = true;
                                    });
                                  },
                                  child: const Text('Đồng ý'),
                                )
                              ],
                            ),
                          if (item.isAccepted != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(item.isAccepted == true
                                  ? "Đã chấp nhận"
                                  : "Đã từ chối"),
                            )
                        ],
                      ),
                      trailing: item.isRead
                          ? const SizedBox(
                              width: 16,
                            )
                          : Icon(
                              Icons.circle,
                              color: Theme.of(context).colorScheme.primary,
                              size: 16,
                            ),
                    );
                  })),
              onRefresh: () async {
                _pagingController.refresh();
              });
        },
      ),
    );
  }

  List<TextSpan> highlightText(String text, String mainText) {
    int index = text.indexOf(mainText);
    if (index == -1)
      return [
        TextSpan(text: text)
      ]; // Nếu không tìm thấy, hiển thị nguyên văn bản

    return [
      if (index > 0)
        TextSpan(
            text: text.substring(0, index),
            style: const TextStyle(fontWeight: FontWeight.bold)),
      TextSpan(text: mainText), // Đoạn chính giữ nguyên định dạng
      if (index + mainText.length < text.length)
        TextSpan(
            text: text.substring(index + mainText.length),
            style: const TextStyle(fontWeight: FontWeight.bold)),
    ];
  }
}
