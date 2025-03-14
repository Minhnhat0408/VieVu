import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/core/utils/conversions.dart';
import 'package:vn_travel_companion/core/utils/display_modal.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/features/auth/presentation/pages/profile_page.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_member.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip_member/trip_member_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/widgets/modals/trip_edit_modal.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TripMembersPage extends StatefulWidget {
  final Trip trip;
  const TripMembersPage({super.key, required this.trip});

  @override
  State<TripMembersPage> createState() => _TripMembersPageState();
}

class _TripMembersPageState extends State<TripMembersPage> {
  final List<TripMember> tripMembers = [];
  bool isAUthorize = false;

  @override
  void initState() {
    super.initState();
    final userId =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
    if (context.read<TripMemberBloc>().state is TripMemberLoadedSuccess) {
      final state =
          context.read<TripMemberBloc>().state as TripMemberLoadedSuccess;
      setState(() {
        tripMembers.addAll(state.tripMembers);
      });
      final me = tripMembers.indexWhere(
        (element) => element.user.id == userId,
      );

      if (me != -1) {
        if (tripMembers[me].role == 'owner' ||
            tripMembers[me].role == 'moderator') {
          setState(() {
            isAUthorize = true;
          });
        }
      }
    }

    // context.read<TripMemberBloc>().add(GetTripMembersEvent(widget.trip.id));
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const PageStorageKey('trip-members-page'),
      slivers: [
        SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
        if (widget.trip.maxMember != null)
          SliverAppBar(
            leading: null,
            primary: false,
            floating: true,
            title: widget.trip.maxMember != null
                ? SizedBox(
                    height: 40, // Giới hạn chiều cao
                    child: Row(
                      children: [
                        Text(
                          'Thành viên ${tripMembers.length}/${widget.trip.maxMember ?? 0}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
            actions: [
              FilledButton(
                onPressed: () {},
                child: const Text(
                  'Mời',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
            pinned: true,
            automaticallyImplyLeading: false,
          ),
        BlocConsumer<TripMemberBloc, TripMemberState>(
          listener: (context, state) {
            if (state is TripMemberLoadedSuccess) {
              setState(() {
                tripMembers.addAll(state.tripMembers);
              });
            }

            if (state is TripMemberFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                ),
              );
            }

            if (state is TripMemberDeletedSuccess) {
              setState(() {
                tripMembers.removeWhere(
                    (element) => element.user.id == state.tripMemberId);
              });
              showSnackbar(context, 'Đã xóa thành viên khỏi chuyến đi');
            }

            if (state is TripMemberInsertedSuccess) {
              setState(() {
                tripMembers.add(state.tripMember);
              });
            }

            if (state is TripMemberUpdatedSuccess) {
              showSnackbar(context, 'Cập nhật thành công');
              setState(() {
                tripMembers[tripMembers.indexWhere((element) =>
                        element.user.id == state.tripMember.user.id)] =
                    state.tripMember;
              });
            }
          },
          builder: (context, state) {
            return widget.trip.maxMember != null
                ? state is TripMemberLoading
                    ? const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : tripMembers.isNotEmpty
                        ? SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final tripMember = tripMembers[index];

                                return Slidable(
                                  closeOnScroll: true,
                                  // controller: slidableController,
                                  enabled: isAUthorize &&
                                      tripMember.user.id !=
                                          (context.read<AppUserCubit>().state
                                                  as AppUserLoggedIn)
                                              .user
                                              .id &&
                                      tripMember.role != 'owner' &&
                                      widget.trip.status != 'cancelled' &&
                                      widget.trip.status != 'completed',

                                  startActionPane: ActionPane(
                                    motion: const BehindMotion(),
                                    extentRatio:
                                        tripMember.role == 'owner' ? 0.4 : 0.28,
                                    children: [
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      if (tripMember.role == 'owner')
                                        IconButton(
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (context) => AlertDialog(
                                                          title: const Text(
                                                              'Xác nhận'),
                                                          content: Text(
                                                              'Bạn có chắc chắn muốn ${tripMember.role == 'member' ? 'chuyển thành quản trị viên' : 'chuyển thành thành viên'}?'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: const Text(
                                                                  'Hủy bỏ'),
                                                            ),
                                                            FilledButton(
                                                              onPressed: () {
                                                                context.read<TripMemberBloc>().add(UpdateTripMember(
                                                                    tripId:
                                                                        widget
                                                                            .trip
                                                                            .id,
                                                                    userId:
                                                                        tripMember
                                                                            .user
                                                                            .id,
                                                                    role: tripMember.role ==
                                                                            'member'
                                                                        ? 'moderator'
                                                                        : 'member'));
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: const Text(
                                                                'Tiếp tục',
                                                              ),
                                                            ),
                                                          ],
                                                        ));
                                          },
                                          tooltip: tripMember.role == 'member'
                                              ? 'Chuyển thành quản trị viên'
                                              : 'Chuyển thành thành viên',
                                          style: IconButton.styleFrom(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .tertiaryContainer,
                                            foregroundColor: Theme.of(context)
                                                .colorScheme
                                                .tertiary,
                                          ),
                                          icon: Icon(
                                            tripMember.role == 'member'
                                                ? Icons.add_moderator
                                                : Icons.person,
                                          ),
                                        ),
                                      IconButton(
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                    title:
                                                        const Text('Xác nhận'),
                                                    content: const Text(
                                                        'Bạn có chắc chắn muốn đuổi thành viên này khỏi chuyến đi?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                            'Hủy bỏ'),
                                                      ),
                                                      FilledButton(
                                                        onPressed: () {
                                                          context
                                                              .read<
                                                                  TripMemberBloc>()
                                                              .add(DeleteTripMember(
                                                                  tripId: widget
                                                                      .trip.id,
                                                                  userId:
                                                                      tripMember
                                                                          .user
                                                                          .id));
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                            'Xác nhận'),
                                                      ),
                                                    ],
                                                  ));
                                        },
                                        tooltip: 'Đuổi khỏi chuyến đi',
                                        style: IconButton.styleFrom(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .secondaryContainer,
                                          foregroundColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                        icon: const Icon(Icons.exit_to_app),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                    title:
                                                        const Text('Xác nhận'),
                                                    content: Text(
                                                        'Bạn có chắc chắn muốn ${tripMember.isBanned ? 'bỏ cấm' : 'cấm'} thành viên này khỏi chuyến đi?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                            'Hủy bỏ'),
                                                      ),
                                                      FilledButton(
                                                        onPressed: () {
                                                          context
                                                              .read<
                                                                  TripMemberBloc>()
                                                              .add(UpdateTripMember(
                                                                  tripId: widget
                                                                      .trip.id,
                                                                  userId:
                                                                      tripMember
                                                                          .user
                                                                          .id,
                                                                  isBanned:
                                                                      !tripMember
                                                                          .isBanned));
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text(
                                                          tripMember.isBanned
                                                              ? 'Bỏ cấm'
                                                              : 'Cấm',
                                                        ),
                                                      ),
                                                    ],
                                                  ));
                                        },
                                        tooltip: tripMember.isBanned
                                            ? 'Bỏ cấm'
                                            : 'Cấm',
                                        style: IconButton.styleFrom(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .errorContainer,
                                          foregroundColor: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        ),
                                        icon: tripMember.isBanned
                                            ? const Icon(Icons.check)
                                            : const Icon(Icons.block),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    leading: CachedNetworkImage(
                                      imageUrl: tripMember.user.avatarUrl ??
                                          'https://via.placeholder.com/150',
                                      imageBuilder: (context, imageProvider) =>
                                          CircleAvatar(
                                        backgroundImage: imageProvider,
                                      ),
                                      placeholder: (context, url) =>
                                          const CircleAvatar(
                                        child: Icon(Icons.person),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const CircleAvatar(
                                        child: Icon(Icons.person),
                                      ),
                                    ),
                                    title: Text(
                                        "${tripMember.user.lastName} ${tripMember.user.firstName}"),
                                    subtitle: Text(
                                        convertRoleToString(tripMember.role),
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                            fontSize: 12)),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.chevron_right,
                                        size: 30,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => ProfilePage(
                                              id: tripMember.user.id,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                              childCount: tripMembers.length,
                            ),
                          )
                        : SliverFillRemaining(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50.0, vertical: 50),
                              child: Column(
                                children: [
                                  const Text(
                                    "Chưa có thành viên nào. Hãy công khai chuyến đi của bạn để mọi người tham gia hoặc mời!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.fromLTRB(
                                          14, 10, 20, 10),
                                    ),
                                    onPressed: () async {
                                      // // Your action here
                                      // final opt = await displayModal(
                                      //     context,
                                      //     const AddItineraryOptionsModal(),
                                      //     null,
                                      //     false);

                                      // if (opt == 'select_saved') {
                                      //   context
                                      //       .read<SavedServiceBloc>()
                                      //       .add(GetSavedServices(
                                      //         tripId: widget.trip.id,
                                      //       ));

                                      //   displayModal(
                                      //       context,
                                      //       SelectSavedServiceToItineraryModal(
                                      //           tripId: widget.trip.id,
                                      //           time: panel),
                                      //       null,
                                      //       true);
                                      // } else {
                                      //   displayFullScreenModal(
                                      //       context,
                                      //       BlocProvider(
                                      //         create: (context) => serviceLocator<
                                      //             LocationInfoCubit>(),
                                      //         child: AddCustomPlaceModal(
                                      //           tripId: widget.trip.id,
                                      //           date: panel,
                                      //         ),
                                      //       ));
                                      // }
                                    },
                                    child: const IntrinsicWidth(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.add,
                                            size: 20,
                                          ),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Text('Thêm'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                : SliverFillRemaining(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50.0, vertical: 50),
                      child: Column(
                        children: [
                          const Text(
                            "Hãy thiết lập số lượng thành viên tối đa cho chuyến đi của bạn trước khi thêm thành viên!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16, fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.fromLTRB(14, 10, 20, 10),
                            ),
                            onPressed: () {
                              displayFullScreenModal(
                                context,
                                TripEditModal(
                                  trip: widget.trip,
                                ),
                              );
                            },
                            child: const IntrinsicWidth(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add,
                                    size: 20,
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Text('Thiết lập'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
          },
        ),
      ],
    );
  }
}
