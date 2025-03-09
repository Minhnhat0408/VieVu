import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:vn_travel_companion/core/constants/transport_options.dart';
import 'package:vn_travel_companion/core/utils/calculate_distance.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';

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
        // BlocConsumer<SubjectBloc, SubjectState>(
        //   listener: (context, state) {
        //     // TODO: implement listener
        //   },
        //   builder: (context, state) {
        //     return SliverToBoxAdapter(
        //       child: ListTile(
        //         title: Text(
        //           'Thành viên',
        //           style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        //               color: Theme.of(context).colorScheme.primary,
        //               fontWeight: FontWeight.bold),
        //         ),
        //         subtitle: Padding(
        //           padding: const EdgeInsets.only(top: 4.0),
        //           child: Row(
        //             children: [
        //               Icon(
        //                 Icons.people,
        //                 color: Theme.of(context).colorScheme.primary,
        //               ),
        //               const SizedBox(width: 6),
        //               Text(trip.maxMember != null
        //                   ? '0/${trip.maxMember} thành viên'
        //                   : 'Chưa có thành viên'),
        //             ],
        //           ),
        //         ),
        //       ),
        //     );
        //   },
        // ),
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
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
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
