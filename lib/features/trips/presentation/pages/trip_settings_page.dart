import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/core/layouts/custom_appbar.dart';
import 'package:vn_travel_companion/core/utils/display_modal.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:vn_travel_companion/features/chat/presentation/pages/chat_details_page.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_member.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip/trip_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip_member/trip_member_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/cubit/current_trip_member_info_cubit.dart';
import 'package:vn_travel_companion/features/trips/presentation/cubit/trip_details_cubit.dart';

import 'package:vn_travel_companion/features/trips/presentation/widgets/modals/trip_edit_modal.dart';
import 'package:vn_travel_companion/features/trips/presentation/widgets/modals/trip_privacy_modal.dart';

final Map<String, String> optionLists = {
  // 'Chỉnh sửa': 'Thay đổi các thông tin hiển thị của chuyến đi',
  // 'Người tham gia': 'Quản lý thành viên trong chuyến đi',
  'Nhóm chat': 'Chat với mọi người trong chuyến đi',
  'Quyền riêng tư': 'Công khai hoặc ẩn chuyến đi',
  // 'Báo cáo': 'Báo cáo chuyến đi không phù hợp',
};

final List<TripSettingOptions> tripSettingOptions = [
  TripSettingOptions('Chia sẻ chuyến đi', const Icon(Icons.share)),
  // TripSettingOptions('Tạo bản sao chuyến đi', const Icon(Icons.copy)),
  // TripSettingOptions(
  //   'Xóa chuyến đi',
  //   const Icon(Icons.delete, color: Colors.red),
  // ),
];

class TripSettingOptions {
  final String title;
  final Icon icon;

  TripSettingOptions(this.title, this.icon);
}

class TripSettingsPage extends StatefulWidget {
  static const String routeName = '/trip-settings';
  final Trip? trip;

  const TripSettingsPage({super.key, required this.trip});

  @override
  State<TripSettingsPage> createState() => _TripSettingsPageState();
}

class _TripSettingsPageState extends State<TripSettingsPage> {
  late TripMember? currentUser;
  @override
  void initState() {
    super.initState();
    currentUser = (context.read<CurrentTripMemberInfoCubit>().state
            as CurrentTripMemberInfoLoaded)
        .tripMember;
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbar(
      appBarTitle: 'Cài đặt chuyến đi',
      centerTitle: true,
      body: MultiBlocListener(
        listeners: [
          BlocListener<TripBloc, TripState>(
            listener: (context, state) {
              if (state is TripActionSuccess) {
                Navigator.of(context).pop();
              }

              if (state is TripDeletedSuccess) {
                Navigator.of(context)
                  ..pop()
                  ..pop();
              }
            },
          ),
          BlocListener<ChatBloc, ChatState>(
            listener: (context, state) {
              if (state is ChatLoadedSuccess) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatDetailsPage(chat: state.chat),
                  ),
                );
              }
            },
          ),
          BlocListener<TripMemberBloc, TripMemberState>(
            listener: (context, state) {
              if (state is TripMemberDeletedSuccess) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
        child: ListView(
          children: [
            if (currentUser?.role == 'owner')
              Column(
                children: [
                  ListTile(
                    title: const Text("Chỉnh sửa",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        )),
                    minVerticalPadding: 16,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    subtitle: const Text(
                        'Thay đổi các thông tin hiển thị của chuyến đi'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      if (widget.trip!.status == 'cancelled' ||
                          widget.trip!.status == 'completed') {
                        showSnackbar(
                            context,
                            'Chuyến đi đã vào trạng thái lưu, không thể chỉnh sửa',
                            'error');
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TripEditModal(
                            trip: widget.trip!,
                          ),
                        ),
                      );

                      // Change privacy
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: Divider(
                      thickness: 2,
                      height: 2,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ...optionLists.entries.map((entry) {
              return Column(
                children: [
                  ListTile(
                    title: Text(entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        )),
                    minVerticalPadding: 16,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    subtitle: Text(entry.value),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      if (entry.key == 'Nhóm chat') {
                        if (widget.trip != null && widget.trip!.isPublished) {
                          context
                              .read<ChatBloc>()
                              .add(GetSingleChat(tripId: widget.trip!.id));
                        } else {
                          showSnackbar(
                              context,
                              'Công khai chuyến đi để bắt đầu chat với mọi người',
                              'error');
                        }
                      } else if (entry.key == 'Quyền riêng tư') {
                        if (widget.trip!.status == 'cancelled' ||
                            widget.trip!.status == 'completed') {
                          showSnackbar(
                              context,
                              'Chuyến đi đã vào trạng thái lưu, không thể chỉnh sửa',
                              'error');
                          return;
                        }

                        displayModal(context,
                            TripPrivacyModal(trip: widget.trip!), null, false);
                        // Share trip
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: Divider(
                      thickness: 2,
                      height: 2,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 16), // Space between two lists

            // Second list (tripSettingOptions)
            ...tripSettingOptions.map((option) {
              return Column(
                children: [
                  ListTile(
                      title: Text(
                        option.title,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      leading: option.icon,
                      onTap: () {
                        // Handle each option's action
                      }),
                ],
              );
            }),
            if (currentUser?.role == 'owner' &&
                widget.trip!.isPublished &&
                widget.trip!.status == 'ongoing')
              Column(
                children: [
                  if (currentUser != null)
                    ListTile(
                      title: Text('Hoàn thành chuyến đi',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary)),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      leading: Icon(Icons.done_all_outlined,
                          color: Theme.of(context).colorScheme.primary),
                      onTap: () {
                        // Handle each option's action
                        if (currentUser?.role == 'owner') {
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Hoàn thành chuyến đi sớm ?'),
                              content: const Text(
                                  'Chuyến đi sẽ tự động hoàn thành sau ngày kết thúc lịch trình. Bạn có muốn hoàn thành chuyến đi ngay bây giờ?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, 'Hủy bỏ'),
                                  child: const Text('Hủy bỏ'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(
                                      context,
                                    );
                                    final tripId = (context
                                            .read<TripDetailsCubit>()
                                            .state as TripDetailsLoadedSuccess)
                                        .trip
                                        .id;
                                    context.read<TripBloc>().add(UpdateTrip(
                                        tripId: tripId, status: 'completed'));
                                  },
                                  child: const Text('Hoàn thành chuyến đi'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
            if (currentUser?.role == 'owner' &&
                widget.trip!.isPublished &&
                widget.trip!.status != 'cancelled' &&
                widget.trip!.status != 'completed')
              Column(
                children: [
                  if (currentUser != null)
                    ListTile(
                      title: const Text('Hủy chuyến đi',
                          style: TextStyle(
                              color: Color.fromARGB(255, 209, 131, 15))),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      leading: const Icon(Icons.cancel_outlined,
                          color: Color.fromARGB(255, 209, 131, 15)),
                      onTap: () {
                        // Handle each option's action
                        if (currentUser?.role == 'owner') {
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Bạn có muốn hủy chuyến đi?'),
                              content: const Text(
                                  'Sau khi hủy chuyến đi sẽ không thể sử dụng và ở trạng thái lưu trữ.'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, 'Hủy bỏ'),
                                  child: const Text('Hủy bỏ'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(
                                      context,
                                    );
                                    final tripId = (context
                                            .read<TripDetailsCubit>()
                                            .state as TripDetailsLoadedSuccess)
                                        .trip
                                        .id;
                                    context.read<TripBloc>().add(UpdateTrip(
                                        tripId: tripId, status: 'cancelled'));
                                  },
                                  child: const Text('Hủy chuyến đi'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
            if (currentUser?.role != 'owner' ||
                (currentUser?.role == 'owner' &&
                    (!widget.trip!.isPublished ||
                        ((widget.trip!.status == 'cancelled' ||
                                widget.trip!.status == "completed") &&
                            widget.trip!.isPublished))))
              Column(
                children: [
                  if (currentUser != null)
                    ListTile(
                      title: Text(
                          currentUser?.role == 'owner'
                              ? 'Xóa chuyến đi'
                              : 'Rời chuyến đi',
                          style: const TextStyle(color: Colors.red)),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      leading: const Icon(Icons.delete, color: Colors.red),
                      onTap: () {
                        // Handle each option's action
                        if (currentUser?.role == 'owner') {
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Bạn có muốn xóa?'),
                              content:
                                  const Text('Chuyến đi sẽ bị xóa vĩnh viễn'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, 'Hủy bỏ'),
                                  child: const Text('Hủy bỏ'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, 'Xóa');
                                    final tripId = (context
                                            .read<TripDetailsCubit>()
                                            .state as TripDetailsLoadedSuccess)
                                        .trip
                                        .id;
                                    context
                                        .read<TripBloc>()
                                        .add(DeleteTrip(id: tripId));
                                  },
                                  child: const Text('Xóa'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Rời chuyến đi?'),
                              content: const Text(
                                  'Bạn có chắc chắn muốn rời chuyến đi?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, 'Hủy bỏ'),
                                  child: const Text('Hủy bỏ'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, 'Rời chuyến đi');
                                    final tripId = (context
                                            .read<TripDetailsCubit>()
                                            .state as TripDetailsLoadedSuccess)
                                        .trip
                                        .id;
                                    context
                                        .read<TripMemberBloc>()
                                        .add(DeleteTripMember(
                                          tripId: tripId,
                                          userId: currentUser!.user.id,
                                        ));
                                  },
                                  child: const Text('Rời chuyến đi'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                ],
              )
          ],
        ),
      ),
    );
  }
}
