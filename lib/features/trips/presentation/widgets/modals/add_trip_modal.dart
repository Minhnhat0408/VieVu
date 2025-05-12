import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vievu/core/utils/show_snackbar.dart';
import 'package:vievu/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:vievu/features/trips/presentation/bloc/trip/trip_bloc.dart';

class AddTripModal extends StatefulWidget {
  const AddTripModal({super.key});

  @override
  State<AddTripModal> createState() => _AddTripModalState();
}

class _AddTripModalState extends State<AddTripModal> {
  final tripName = TextEditingController();
  bool nameIsEmpty = true;
  @override
  void dispose() {
    tripName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TripBloc, TripState>(
      listener: (context, state) {
        if (state is TripActionSuccess) {
          Navigator.of(context).pop();
          context.read<ChatBloc>().add(GetChatHeads());
        }
        if (state is TripLoadedFailure) {
          showSnackbar(context, state.message, 'error');
        }
      },
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 20.0, right: 20, top: 20),
              child: Text(
                "Tạo chuyến đi",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            //TODO: add validate
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: TextField(
                controller: tripName,
                onChanged: (value) => setState(() {
                  nameIsEmpty = value.isEmpty;
                }),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Tên chuyến đi',
                  hintText: 'Ví dụ: Chuyến đi Hội An 2025',
                ),
              ),
            ),
            Divider(
              thickness: 1,
              color: Theme.of(context).colorScheme.primary,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: nameIsEmpty || state is TripActionLoading
                      ? null
                      : () {
                          final userId = (context.read<AppUserCubit>().state
                                  as AppUserLoggedIn)
                              .user
                              .id;

                          context.read<TripBloc>().add(AddTrip(
                                tripName.text,
                                userId,
                              ));
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: state is TripActionLoading
                      ? const Row(
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text('Áp dụng'),
                          ],
                        )
                      : const Text('Tạo chuyến đi'),
                ),
                const SizedBox(width: 20),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        );
      },
    );
  }
}
