import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:vn_travel_companion/core/constants/parent_traveltypes.dart';
import 'package:vn_travel_companion/features/user_preference/domain/entities/travel_type.dart';
import 'package:vn_travel_companion/features/user_preference/presentation/bloc/travel_types/travel_types_bloc.dart';

class FilterAllAtrractionModal extends StatefulWidget {
  final TravelType? currentParentTravelType;
  final List<TravelType> currentTravelTypes;
  final String currentSortType;
  final int? currentRating;
  final int? currentBudget;
  final Function onFilterChanged;

  // final ValueChanged<TravelType?> onTravelTypeChanged;
  const FilterAllAtrractionModal({
    super.key,
    this.currentParentTravelType,
    required this.currentTravelTypes,
    required this.currentSortType,
    this.currentRating,
    this.currentBudget,
    required this.onFilterChanged,
  });

  @override
  State<FilterAllAtrractionModal> createState() =>
      _FilterAllAtrractionModalState();
}

class _FilterAllAtrractionModalState extends State<FilterAllAtrractionModal> {
  late TravelType? _parentTravelType;
  late List<TravelType> _travelTypes;
  late String _sortType;
  late int? _rating;
  late int? _budget;

  @override
  void initState() {
    super.initState();
    _parentTravelType = widget.currentParentTravelType;
    _travelTypes = widget.currentTravelTypes;
    _sortType = widget.currentSortType;
    _rating = widget.currentRating;
    _budget = widget.currentBudget;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20.0, right: 20, top: 10),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "Bộ lọc",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        Divider(
          thickness: 1,
          color: Theme.of(context).colorScheme.primary,
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sắp xếp theo',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: ["hot_score", "avg_rating"].map((sortType) {
                      return OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _sortType = sortType;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: _sortType == sortType
                                ? 2.0
                                : 1.0, // Thicker border
                          ),
                        ),
                        child: Text(
                          sortType == "hot_score"
                              ? "Phổ biến nhất"
                              : "Đánh giá cao nhất",
                          style: TextStyle(
                              fontWeight: _sortType == sortType
                                  ? FontWeight.bold
                                  : FontWeight.normal),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Loại hình du lịch',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: parentTravelTypes.map<Widget>((travelType) {
                      return OutlinedButton(
                        onPressed: () {
                          setState(() {
                            if (_parentTravelType?.id == travelType.id) {
                              _parentTravelType = null;
                              _travelTypes = [];
                            } else {
                              _parentTravelType = travelType;
                            }
                          });
                          context
                              .read<TravelTypesBloc>()
                              .add(GetTravelTypesByParentIds([travelType.id]));
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: _parentTravelType?.id == travelType.id
                                ? 2.0
                                : 1.0, // Thicker border
                          ),
                        ),
                        child: Text(
                          travelType.name,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: _parentTravelType?.id == travelType.id
                                  ? FontWeight.bold
                                  : FontWeight.normal),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  BlocBuilder<TravelTypesBloc, TravelTypesState>(
                    builder: (context, state) {
                      if (state is TravelTypesLoadedSuccess &&
                          _parentTravelType != null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _parentTravelType!.name,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children:
                                  state.travelTypes.map<Widget>((travelType) {
                                return OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      if (_travelTypes.contains(travelType)) {
                                        _travelTypes.remove(travelType);
                                      } else {
                                        _travelTypes.add(travelType);
                                      }
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 4),
                                    side: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: _travelTypes.contains(travelType)
                                          ? 2.0
                                          : 1.0, // Thicker border
                                    ),
                                  ),
                                  child: Text(
                                    travelType.name,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight:
                                            _travelTypes.contains(travelType)
                                                ? FontWeight.bold
                                                : FontWeight.normal),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Đánh giá',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [5, 4, 3, 2].map((rating) {
                      return OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _rating = rating;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width:
                                _rating == rating ? 2.0 : 1.0, // Thicker border
                          ),
                        ),
                        child: RatingBarIndicator(
                          rating: rating.toDouble(),
                          itemSize: 20,
                          direction: Axis.horizontal,
                          itemCount: 5,
                          itemBuilder: (context, _) => Icon(
                            Icons.favorite,
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Đánh giá',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      "Miễn phí",
                      "Giá bình dân",
                      "Giá trung bình",
                      "Giá cao"
                    ].asMap().entries.map((entry) {
                      int index = entry.key;
                      String budget = entry.value;
                      return OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _budget = index; // Use index here
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: _budget == index
                                ? 2.0
                                : 1.0, // Thicker border for selected index
                          ),
                        ),
                        child: Text(
                          budget,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: _budget == index
                                ? FontWeight.bold
                                : FontWeight.normal, // Bold for selected index
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
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
                    _sortType = "hot_score";
                    _parentTravelType = null;
                    _travelTypes = [];
                    _rating = null;
                    _budget = null;
                  });
                },
                child: const Text("Hủy",
                    style: TextStyle(decoration: TextDecoration.underline))),
            ElevatedButton(
              onPressed: () {
                widget.onFilterChanged(_sortType, _parentTravelType,
                    _travelTypes, _rating, _budget);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: const Text("Áp dụng"),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
