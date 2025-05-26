
import 'package:flutter/material.dart';
import 'package:vievu/features/trips/domain/entities/trip.dart';
import 'package:vievu/features/trips/domain/entities/trip_member.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/features/trips/presentation/bloc/trip_member/trip_member_bloc.dart';

class BannedUserModal extends StatefulWidget {
  final Trip trip;
  const BannedUserModal({
    super.key,
    required this.trip,
  });

  @override
  State<BannedUserModal> createState() => _BannedUserModalState();
}

class _BannedUserModalState extends State<BannedUserModal> {
  final List<TripMember> bannedUsers = [];

  @override
  void initState() {
    super.initState();
    context.read<TripMemberBloc>().add(GetBannedUsers(
          tripId: widget.trip.id,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(
              width: 30,
            ),
            const Text(
              "Danh sách cấm",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
      Divider(
        thickness: 1,
        color: Theme.of(context).colorScheme.primary,
      ),
      Expanded(
        child: BlocConsumer<TripMemberBloc, TripMemberState>(
          listener: (context, state) {
            if (state is BannedUserLoadedSuccess) {
              bannedUsers.addAll(state.users);
            }
            if (state is TripMemberUpdatedSuccess) {
              if (state.tripMember.isBanned == false) {
                bannedUsers.removeWhere(
                    (user) => user.user.id == state.tripMember.user.id);
              }
            }
          },
          builder: (context, state) {
            if (state is TripMemberLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TripMemberFailure) {
              return Center(child: Text(state.message));
            } else {
              if (bannedUsers.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("Không có ai trong danh sách cấm."),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: bannedUsers.length,
                itemBuilder: (context, index) {
                  final user = bannedUsers[index];
                  return ListTile(
                    title: Text("${user.user.lastName} ${user.user.firstName}",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        )),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      style: IconButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: const Text('Bỏ cấm thành viên'),
                                  content: Text(
                                      'Bạn có chắc chắn muốn bỏ cấm ${user.user.lastName} ${user.user.firstName} không?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Hủy bỏ'),
                                    ),
                                    FilledButton(
                                      onPressed: () {
                                        context.read<TripMemberBloc>().add(
                                            UpdateTripMember(
                                                tripId: widget.trip.id,
                                                userId: user.user.id,
                                                isBanned: false));

                                        Navigator.of(context).pop();
                                      },
                                      child: const Text(
                                        'Tiếp tục',
                                      ),
                                    ),
                                  ],
                                ));
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    ]);
  }
}
