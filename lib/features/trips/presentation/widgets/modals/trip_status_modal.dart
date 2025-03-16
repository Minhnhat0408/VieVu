 import 'package:flutter/material.dart';
import 'package:vn_travel_companion/core/constants/trip_filters.dart';

class TripStatusModal extends StatefulWidget {
  final TripStatus? currentStatus;
  final ValueChanged<TripStatus?> onStatusChanged;
  const TripStatusModal(
      {super.key, this.currentStatus, required this.onStatusChanged});

  @override
  State<TripStatusModal> createState() => _TripStatusModalState();
}

class _TripStatusModalState extends State<TripStatusModal> {
  late TripStatus? _status;

  @override
  void initState() {
    super.initState();
    _status = widget.currentStatus;
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
                ...tripStatusList.map(
                  (status) {
                    return RadioListTile(
                      value: status,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 20),
                      groupValue: _status,
                      controlAffinity: ListTileControlAffinity.trailing,
                      title: Text(
                        status.label,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _status = value;
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
                    _status = null;
                  });
                },
                child: const Text("Hủy",
                    style: TextStyle(decoration: TextDecoration.underline))),
            ElevatedButton(
              onPressed: () {
                widget.onStatusChanged(_status);
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
