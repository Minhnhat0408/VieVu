import 'package:flutter/material.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';

class TripInfoPage extends StatelessWidget {
  final Trip trip;
  const TripInfoPage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4),
      child: Column(
        children: [
          ListTile(
            title: Text(
              'Thời gian',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold),
            ),
            subtitle: const Padding(
              padding: EdgeInsets.only(top: 2.0),
              child: Text(
                '10/10/2021 - 20/10/2021 (10 ngày)',
              ),
            ),
          ),
          ListTile(
            title: Text(
              'Mô tả',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(trip.description ?? 'Chưa có mô'),
            ),
          ),
          ListTile(
            title: Text(
              'Phương tiện',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Badge(
                    label: const Icon(
                      Icons.flight,
                      size: 20,
                    ),
                    alignment: Alignment.center,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    padding: const EdgeInsets.all(5),
                  ),
                  const SizedBox(width: 4),
                  Badge(
                    label: const Icon(
                      Icons.train,
                      size: 20,
                    ),
                    alignment: Alignment.center,
                    backgroundColor:
                        Theme.of(context).colorScheme.tertiaryContainer,
                    padding: const EdgeInsets.all(5),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            title: Text(
              'Thành viên',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(trip.maxMember != null
                  ? '0/${trip.maxMember} thành viên'
                  : 'Chưa có thành viên'),
            ),
          ),
          ListTile(
            title: Text(
              'Trạng thái',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold),
            ),
            subtitle: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(top: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: trip.status == 'planning'
                      ? Theme.of(context).colorScheme.primary
                      : trip.status == 'going'
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  trip.status == 'planning'
                      ? 'Đang lên kế hoạch'
                      : trip.status == 'going'
                          ? 'Đang diễn ra'
                          : 'Đã kết thúc',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
