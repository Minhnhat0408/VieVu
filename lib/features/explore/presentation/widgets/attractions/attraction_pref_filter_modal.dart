
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/core/constants/parent_traveltypes.dart';
import 'package:vievu/features/user_preference/domain/entities/travel_type.dart';
import 'package:vievu/features/user_preference/presentation/bloc/travel_types/travel_types_bloc.dart';

class AttractionPrefFilterModal extends StatefulWidget {
  final Map<String, double> prefsDF;
  const AttractionPrefFilterModal({super.key, required this.prefsDF});

  @override
  State<AttractionPrefFilterModal> createState() =>
      _AttractionPrefFilterModalState();
}

class _AttractionPrefFilterModalState extends State<AttractionPrefFilterModal> {
  final List<bool> _expanded =
      List.generate(parentTravelTypes.length, (index) => false);
  final Map<String, List<TravelType>> _childTravelTypes = {};
  late Map<String, double> _prefsDF;
  @override
  void initState() {
    super.initState();
    _prefsDF = Map<String, double>.from(widget.prefsDF);
    context.read<TravelTypesBloc>().add(
        GetTravelTypesByParentIds(parentTravelTypes.map((e) => e.id).toList()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        leading: null,
        title: const Text('Lọc theo sở thích'),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: BlocConsumer<TravelTypesBloc, TravelTypesState>(
        listener: (context, state) {
          if (state is TravelTypesLoadedSuccess) {
            for (final travelType in state.travelTypes) {
              if (_childTravelTypes[travelType.parentId] == null) {
                _childTravelTypes[travelType.parentId!] = [];
              }
              _childTravelTypes[travelType.parentId]!.add(travelType);
            }
          }
        },
        builder: (context, state) {
          if (state is TravelTypesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ExpansionPanelList(
                            expandedHeaderPadding: const EdgeInsets.all(0),
                            expansionCallback: (int index, bool isExpanded) {
                              setState(() {
                                _expanded[index] = isExpanded;
                              });
                            },
                            animationDuration:
                                const Duration(milliseconds: 1000),
                            children: [
                              ...parentTravelTypes.asMap().entries.map((item) {
                                final index = item.key;
                                final value = item.value;
                                return ExpansionPanel(
                                  headerBuilder:
                                      (BuildContext context, bool isExpanded) {
                                    return ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                      title: Text(value.name,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                    );
                                  },
                                  canTapOnHeader: true,
                                  body: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Column(
                                        children: _childTravelTypes[value.id]
                                                ?.map<Widget>((travelType) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0,
                                                        horizontal: 20),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      travelType.name,
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Slider(
                                                      value: (_prefsDF[
                                                                  travelType
                                                                      .name] ??
                                                              0)
                                                          .toDouble(),
                                                      min: 0,
                                                      max: 5,
                                                      divisions: 5,
                                                      label: (_prefsDF[
                                                                  travelType
                                                                      .name] ??
                                                              0)
                                                          .toString(),
                                                      onChanged: (newValue) {
                                                        setState(() {
                                                          _prefsDF[travelType
                                                                  .name] =
                                                              newValue
                                                                  .toDouble();
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList() ??
                                            [],
                                      )),
                                  isExpanded: _expanded[index],
                                );
                              }),
                            ]),
                      ],
                    ),
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
                        onPressed: () {
                          setState(() {
                            _prefsDF = Map<String, double>.from(widget.prefsDF);
                          });
                        },
                        child: const Text("Hủy",
                            style: TextStyle(
                                decoration: TextDecoration.underline))),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(_prefsDF);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: const Text("Áp dụng"),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
              ]);
        },
      ),
    );
  }
}
