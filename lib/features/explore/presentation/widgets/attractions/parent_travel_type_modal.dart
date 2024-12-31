import 'package:flutter/material.dart';
import 'package:vn_travel_companion/core/constants/parent_traveltypes.dart';
import 'package:vn_travel_companion/features/user_preference/domain/entities/travel_type.dart';

class ParentTravelTypeModal extends StatefulWidget {
  final TravelType? currentTravelType;
  final ValueChanged<TravelType?> onTravelTypeChanged;
  const ParentTravelTypeModal(
      {super.key, this.currentTravelType, required this.onTravelTypeChanged});

  @override
  State<ParentTravelTypeModal> createState() => _ParentTravelTypeModalState();
}

class _ParentTravelTypeModalState extends State<ParentTravelTypeModal> {
  late TravelType? _travelType;

  @override
  void initState() {
    super.initState();
    _travelType = widget.currentTravelType;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                width: 30,
              ),
              const Text(
                "Chọn loại hình du lịch",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        Divider(
          thickness: 1,
          color: Theme.of(context).colorScheme.primary,
        ),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ...parentTravelTypes.map(
                  (travelType) {
                    return RadioListTile(
                      value: travelType,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 20),
                      groupValue: _travelType,
                      controlAffinity: ListTileControlAffinity.trailing,
                      title: Text(
                        travelType.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _travelType = value as TravelType;
                        });
                      },
                    );
                  },
                ),
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
                    _travelType = null;
                  });
                },
                child: const Text("Hủy",
                    style: TextStyle(decoration: TextDecoration.underline))),
            ElevatedButton(
              onPressed: () {
                widget.onTravelTypeChanged(_travelType);
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
