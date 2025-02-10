import 'package:flutter/material.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip/trip_bloc.dart';

class TripPrivacyModal extends StatefulWidget {
  final Trip trip;
  const TripPrivacyModal({
    super.key,
    required this.trip,
  });

  @override
  State<TripPrivacyModal> createState() => _TripPrivacyModalState();
}

class _TripPrivacyModalState extends State<TripPrivacyModal> {
  bool _published = false;

  @override
  void initState() {
    super.initState();
    _published = widget.trip.isPublished;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                width: 30,
              ),
              const Text(
                "Đối tượng có thể xem",
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
        ListTile(
          title: const Text(
            "Hiển thị với mọi người",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: const Text(
              "Cho phép mọi người đều có thể xem chuyến đi của bạn và tham gia"),
          trailing: Switch(
            value: _published,
            onChanged: (value) {
              // widget.onStatusChanged(_status);
              setState(() {
                _published = value;
              });
            },
          ),
        ),
        Divider(
          thickness: 1,
          color: Theme.of(context).colorScheme.primary,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
                onPressed: () {},
                child: const Text("Hủy",
                    style: TextStyle(decoration: TextDecoration.underline))),
            BlocConsumer<TripBloc, TripState>(
              listener: (context, state) {
                if (state is TripActionSuccess) {
                  Navigator.of(context).pop();
                }
                if (state is TripActionFailure) {
                  Navigator.of(context).pop();

                  showSnackbar(context, state.message, SnackBarState.error);
                }
              },
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: () {
                    // widget.onStatusChanged(_status);
                    if (_published != widget.trip.isPublished) {
                      context.read<TripBloc>().add(UpdateTrip(
                            isPublished: _published,
                            tripId: widget.trip.id,
                          ));
                      // Update trip
                    }
                    // Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: state is TripActionLoading
                      ? Row(
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text("Đang cập nhật"),
                          ],
                        )
                      : const Text("Áp dụng"),
                );
              },
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
