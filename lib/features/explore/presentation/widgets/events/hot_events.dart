import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vievu/features/explore/domain/entities/event.dart';
import 'package:vievu/features/explore/presentation/bloc/event/event_bloc.dart';
import 'package:vievu/features/explore/presentation/cubit/location_info/location_info_cubit.dart';
import 'package:vievu/features/explore/presentation/widgets/events/event_big_card.dart';
import 'package:vievu/init_dependencies.dart';

class HotEventsSection extends StatelessWidget {
  const HotEventsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => serviceLocator<LocationInfoCubit>(),
        ),
      ],
      child: const HotEventsSectionContent(),
    );
  }
}

class HotEventsSectionContent extends StatefulWidget {
  const HotEventsSectionContent({super.key});

  @override
  State<HotEventsSectionContent> createState() =>
      _HotEventsSectionContentState();
}

class _HotEventsSectionContentState extends State<HotEventsSectionContent> {
  List<Event>? events;
  @override
  void initState() {
    super.initState();
    final userId =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
    BlocProvider.of<EventBloc>(context).add(GetHotEvents(userId: userId));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Sự kiện xu hướng trên TicketBox',
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        BlocConsumer<EventBloc, EventState>(
          listener: (context, state) {
            if (state is EventFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                ),
              );
            }

            if (state is EventLoadedSuccess) {
              setState(() {
                events = state.events;
              });
            }
          },
          builder: (context, state) {
            if (state is EventLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (events != null) {
              return SizedBox(
                height: 300,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: events!.length,
                  itemBuilder: (context, index) {
                    final event = events![index];
                    return Padding(
                        padding: EdgeInsets.only(
                          left: index == 0
                              ? 20.0
                              : 4.0, // Extra padding for the first item
                          right: index == 9
                              ? 20.0
                              : 4.0, // Extra padding for the last item
                        ),
                        child: EventBigCard(
                          event: event,
                          onSavedChanged: (int id, bool saveState) {
                            setState(() {
                              // replace the saved status of the attraction by attraction 's id
                              events!
                                  .where((element) => element.id == id)
                                  .first
                                  .isSaved = saveState;
                            });
                          },
                        ));
                  },
                ),
              );
            }

            return Container();
          },
        ),
      ],
    );
  }
}
