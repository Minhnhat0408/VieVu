import 'package:flutter/material.dart';
import 'package:vievu/core/constants/restaurant_filters.dart';

class RestaurantFilterModal extends StatefulWidget {
  final String? currentFilter;
  final ValueChanged<String?> onFilterChanged;
  const RestaurantFilterModal(
      {super.key, this.currentFilter, required this.onFilterChanged});

  @override
  State<RestaurantFilterModal> createState() => _RestaurantFilterModalState();
}

class _RestaurantFilterModalState extends State<RestaurantFilterModal> {
  late String? _seletedFilter;

  @override
  void initState() {
    super.initState();
    _seletedFilter = widget.currentFilter;
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
                "Ẩm thực",
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
                ...restaurantFilterOptions.entries.map(
                  (filter) {
                    return RadioListTile(
                      value: filter.key,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 20),
                      groupValue: _seletedFilter,
                      controlAffinity: ListTileControlAffinity.trailing,
                      title: Text(
                        filter.key,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _seletedFilter = value as String;
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
                    _seletedFilter = null;
                  });
                },
                child: const Text("Hủy",
                    style: TextStyle(decoration: TextDecoration.underline))),
            ElevatedButton(
              onPressed: () {
                widget.onFilterChanged(_seletedFilter);
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
