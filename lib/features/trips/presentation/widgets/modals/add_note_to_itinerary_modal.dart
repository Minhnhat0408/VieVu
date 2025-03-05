import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip_itinerary.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip_itinerary/trip_itinerary_bloc.dart';

class AddNoteToItineraryModal extends StatefulWidget {
  final TripItinerary tripItinerary;
  const AddNoteToItineraryModal({
    super.key,
    required this.tripItinerary,
  });

  @override
  State<AddNoteToItineraryModal> createState() =>
      _AddNoteToItineraryModalState();
}

class _AddNoteToItineraryModalState extends State<AddNoteToItineraryModal> {
  final tripName = TextEditingController();
  bool nameIsEmpty = true;

  @override
  void initState() {
    tripName.text = widget.tripItinerary.note ?? '';
    super.initState();
  }

  @override
  void dispose() {
    tripName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TripItineraryBloc, TripItineraryState>(
      listener: (context, state) {
        if (state is TripItineraryUpdatedSuccess) {
          Navigator.of(context).pop();
        }
        if (state is TripItineraryFailure) {
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
                "Thêm ghi chú",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: TextField(
                controller: tripName,
                maxLines: 5,
                onChanged: (value) => setState(() {
                  nameIsEmpty = value.isEmpty;
                }),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  labelText: 'Ghi chú ',
                  hintText:
                      'Ví dụ: Dừng chân 40 phút, điểm đến này có nhiều cửa hàng lưu niệm... ',
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
                  onPressed: nameIsEmpty || state is TripItineraryLoading
                      ? null
                      : () {
                          context
                              .read<TripItineraryBloc>()
                              .add(UpdateTripItinerary(
                                id: widget.tripItinerary.id,
                                note: tripName.text,
                              ));
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: state is TripItineraryLoading
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
                      : const Text('Thêm'),
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
