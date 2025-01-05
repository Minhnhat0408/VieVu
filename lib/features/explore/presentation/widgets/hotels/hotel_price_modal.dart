import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HotelPriceModal extends StatefulWidget {
  final int? minPrice;
  final int? maxPrice;
  final ValueChanged<List<int>> onServicesChanged;
  const HotelPriceModal(
      {super.key,
      required this.minPrice,
      required this.maxPrice,
      required this.onServicesChanged});

  @override
  State<HotelPriceModal> createState() => _HotelPriceModalState();
}

class _HotelPriceModalState extends State<HotelPriceModal> {
  RangeValues _currentRangeValues = const RangeValues(0, 6300000);

  @override
  void initState() {
    super.initState();
    final double min =
        widget.minPrice != null ? widget.minPrice!.toDouble() : 0.0;
    final double max =
        widget.maxPrice != null ? widget.maxPrice!.toDouble() : 6300000.0;
    _currentRangeValues = RangeValues(min, max);
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
                "Chọn mức giá",
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: RangeSlider(
            values: _currentRangeValues,
            max: 6300000,
            divisions: 630,
            labels: RangeLabels(
                '${NumberFormat('#,###').format(_currentRangeValues.start.round())} vnd',
                '${NumberFormat('#,###').format(_currentRangeValues.end.round())} vnd'),
            onChanged: (RangeValues values) {
              setState(() {
                _currentRangeValues = values;
              });
            },
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
                    _currentRangeValues = const RangeValues(0, 5000000);
                  });
                },
                child: const Text("Hủy",
                    style: TextStyle(decoration: TextDecoration.underline))),
            ElevatedButton(
              onPressed: () {
                widget.onServicesChanged([
                  int.parse(_currentRangeValues.start.round().toString()),
                  int.parse(_currentRangeValues.end.round().toString())
                ]);
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
