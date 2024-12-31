import 'package:flutter/material.dart';

class SortModal extends StatefulWidget {
  final String currentSortType;
  final ValueChanged<String> onSortChanged;

  const SortModal({
    super.key,
    required this.currentSortType,
    required this.onSortChanged,
  });

  @override
  State<SortModal> createState() => _SortModalState();
}

class _SortModalState extends State<SortModal> {
  late String _sortType;

  @override
  void initState() {
    super.initState();
    _sortType = widget.currentSortType;
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
                "Sắp xếp theo",
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
        RadioListTile(
          value: "hot_score",
          groupValue: _sortType,
          controlAffinity: ListTileControlAffinity.trailing,
          title: const Text(
            "Phổ biến nhất",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onChanged: (value) {
            setState(() {
              _sortType = value!;
            });
          },
        ),
        RadioListTile(
          value: "avg_rating",
          groupValue: _sortType,
          controlAffinity: ListTileControlAffinity.trailing,
          title: const Text(
            "Đánh giá cao nhất",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onChanged: (value) {
            setState(() {
              _sortType = value!;
            });
          },
        ),
        Divider(
          thickness: 1,
          color: Theme.of(context).colorScheme.primary,
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSortChanged(_sortType);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          child: const Text("Áp dụng"),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
