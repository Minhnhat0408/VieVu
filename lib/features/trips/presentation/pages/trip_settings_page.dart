import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/core/layouts/custom_appbar.dart';
import 'package:vn_travel_companion/core/utils/display_modal.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip/trip_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/cubit/trip_details_cubit.dart';

import 'package:vn_travel_companion/features/trips/presentation/widgets/trip_edit_modal.dart';

final Map<String, String> optionLists = {
  'Chỉnh sửa': 'Thay đổi các thông tin hiển thị của chuyến đi',
  'Người tham gia': 'Quản lý thành viên trong chuyến đi',
  'Quyền riêng tư': 'Công khai hoặc ẩn chuyến đi',
  'Báo cáo': 'Báo cáo chuyến đi không phù hợp',
};

final List<TripSettingOptions> tripSettingOptions = [
  TripSettingOptions('Chia sẻ chuyến đi', const Icon(Icons.share)),
  TripSettingOptions('Tạo bản sao chuyến đi', const Icon(Icons.copy)),
  TripSettingOptions(
    'Xóa chuyến đi',
    const Icon(Icons.delete, color: Colors.red),
  ),
];

class TripSettingOptions {
  final String title;
  final Icon icon;

  TripSettingOptions(this.title, this.icon);
}

class TripSettingsPage extends StatefulWidget {
  static const String routeName = '/trip-settings';

  const TripSettingsPage({super.key});

  @override
  State<TripSettingsPage> createState() => _TripSettingsPageState();
}

class _TripSettingsPageState extends State<TripSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return CustomAppbar(
      appBarTitle: 'Cài đặt chuyến đi',
      centerTitle: true,
      body: BlocListener<TripBloc, TripState>(
        listener: (context, state) {
          // TODO: implement listener
          if (state is TripActionSuccess) {
            Navigator.of(context).pop();
          }

          if (state is TripDeletedSuccess) {
            Navigator.of(context)
              ..pop()
              ..pop();
          }
        },
        child: ListView(
          children: [
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
                      // Navigator.of(context).pushNamed('/my-trips');
                      if (entry.key == 'Chỉnh sửa') {
                        displayFullScreenModal(
                          context,
                          const TripEditModal(),
                        );
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
                    title: Text(option.title,
                        style: TextStyle(
                            color: option.title == 'Xóa chuyến đi'
                                ? Colors.red
                                : null)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    leading: option.icon,
                    onTap: () {
                      // Handle each option's action
                      if (option.title == 'Xóa chuyến đi') {
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
                      }
                    },
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
