import 'package:flutter/material.dart';
import 'package:vievu/features/user_preference/domain/entities/travel_type.dart';
import 'package:vievu/features/user_preference/presentation/bloc/travel_types/travel_types_bloc.dart';
import 'package:vievu/features/user_preference/presentation/widgets/preferences_option.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/core/common/widgets/loader.dart';
import 'package:vievu/core/utils/show_snackbar.dart';

class ChildTravelTypes extends StatefulWidget {
  final List<TravelType> parentTravelTypesList;
  final List<TravelType> childTravelTypesList;
  final Function onTravelTypesChanged;

  const ChildTravelTypes(
      {super.key,
      required this.parentTravelTypesList,
      required this.childTravelTypesList,
      required this.onTravelTypesChanged});

  @override
  State<ChildTravelTypes> createState() => _ChildTravelTypesState();
}

class _ChildTravelTypesState extends State<ChildTravelTypes> {
  @override
  void initState() {
    super.initState();
    context.read<TravelTypesBloc>().add(GetTravelTypesByParentIds(
        widget.parentTravelTypesList.map((e) => e.id).toList()));
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
                      isSelected: widget.childTravelTypesList
                          .any((item) => item.id == e.id),
                      onTap: () {
                        if (widget.childTravelTypesList
                            .any((item) => item.id == e.id)) {
                          widget.childTravelTypesList
                              .removeWhere((item) => item.id == e.id);
                        } else {
                          widget.childTravelTypesList.add(e);
                        }
                        widget.onTravelTypesChanged();
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
