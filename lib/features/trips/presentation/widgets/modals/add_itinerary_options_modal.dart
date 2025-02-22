import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/core/utils/display_modal.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/location_info/location_info_cubit.dart';
import 'package:vn_travel_companion/features/trips/presentation/widgets/modals/add_custom_place_modal.dart';
import 'package:vn_travel_companion/features/trips/presentation/widgets/modals/select_saved_service_to_itinerary_modal.dart';
import 'package:vn_travel_companion/init_dependencies.dart';

class AddItineraryOptionsModal extends StatelessWidget {
  const AddItineraryOptionsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(
        height: 10,
      ),
      InkWell(
        onTap: () {
          Navigator.pop(context, 'add_new');

        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                'Thêm mục mới',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
      Divider(
        thickness: 1,
        color: Theme.of(context).colorScheme.primary,
      ),
      InkWell(
        onTap: () {
          Navigator.pop(context, 'select_saved');
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                'Chọn từ danh sách',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(
        height: 10,
      ),
    ]);
  }
}
