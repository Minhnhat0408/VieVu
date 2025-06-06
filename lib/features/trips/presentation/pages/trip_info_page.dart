import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vievu/core/constants/transport_options.dart';
import 'package:vievu/core/constants/trip_filters.dart';
import 'package:vievu/core/utils/calculate_distance.dart';
import 'package:vievu/features/trips/domain/entities/trip.dart';

class TripInfoPage extends StatelessWidget {
  final Trip trip;
  const TripInfoPage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const PageStorageKey('trip-info-page'),
      slivers: [
        SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: ListTile(
              title: Text(
                'Thời gian',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: trip.startDate != null
                    ? Row(
                        children: [
                          Icon(
                            Icons.date_range,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "${DateFormat('dd/MM/yyyy').format(trip.startDate!)} - ${DateFormat('dd/MM/yyyy').format(trip.endDate!)} (${calculateDaysBetween(trip.startDate!, trip.endDate!)} ngày)",
                          ),
                        ],
                      )
                    : const Text('Chưa có thời gian'),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ListTile(
            title: Text(
              'Mô tả',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: trip.description != null
                  ? RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Icon(
                              Icons.format_quote_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const WidgetSpan(child: SizedBox(width: 6)),
                          TextSpan(
                            text: trip.description!,
                          ),
                        ],
                      ),
                    )
                  : const Text('Chưa có mô tả'),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ListTile(
            title: Text(
              'Phương tiện',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: trip.transports != null
                    ? Wrap(
                        spacing: 8.0, // Space between badges
                        children: trip.transports!.map((transport) {
                          final option = transportOptions.firstWhere(
                            (element) => element.value == transport,
                          );

                          return Tooltip(
                            message: option.label, // Show label in tooltip
                            child: option.badge,
                          );
                        }).toList(),
                      )
                    : const Text('Chưa có phương tiện')),
          ),
        ),
        SliverToBoxAdapter(
          child: ListTile(
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
                      ? const Color(0xFF90CAF9)
                      : trip.status == 'ongoing'
                          ? const Color(0xFF81C784)
                          : trip.status == 'completed'
                              ? const Color(0xFFFFD54F)
                              : const Color(0xFFE57373),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  tripStatusList
                      .where((element) => element.value == trip.status)
                      .first
                      .label,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ListTile(
            title: Text(
              'Ngày tạo',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                children: [
                  Icon(
                    Icons.av_timer_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('dd/MM/yyyy').format(trip.createdAt),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
