import 'package:flutter/widgets.dart';
import 'package:vievu/features/user_preference/domain/entities/travel_type.dart';
import 'package:vievu/features/user_preference/presentation/bloc/travel_types/travel_types_bloc.dart';
import 'package:vievu/features/user_preference/presentation/widgets/preferences_option.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/core/common/widgets/loader.dart';
import 'package:vievu/core/utils/show_snackbar.dart';

class ParentTravelTypes extends StatefulWidget {
  final List<TravelType> travelTypesList;
  final Function onTravelTypesChanged;
  const ParentTravelTypes(
      {super.key,
      required this.travelTypesList,
      required this.onTravelTypesChanged});

  @override
  State<ParentTravelTypes> createState() => _ParentTravelTypesState();
}

class _ParentTravelTypesState extends State<ParentTravelTypes> {
  @override
  void initState() {
    super.initState();
    context.read<TravelTypesBloc>().add(GetParentTravelTypes());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TravelTypesBloc, TravelTypesState>(
      listener: (context, state) {
        if (state is TravelTypesFailure) {
          showSnackbar(context, state.message);
        }
      },
      builder: (context, state) {
        if (state is TravelTypesLoadedSuccess) {
          return Column(
            children: state.travelTypes
                .map((e) => PrefOption(
                      title: e.name,
                      isSelected:
                          widget.travelTypesList.any((item) => item.id == e.id),
                      onTap: () {
                        if (widget.travelTypesList
                            .any((item) => item.id == e.id)) {
                          widget.travelTypesList
                              .removeWhere((item) => item.id == e.id);
                        } else {
                          widget.travelTypesList.add(e);
                        }
                        widget.onTravelTypesChanged(); // Notify the parent
                      },
                    ))
                .toList(),
          );
        }
        return const Loader();
      },
    );
  }
}
