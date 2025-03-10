import 'package:flutter/material.dart';
import 'package:vn_travel_companion/core/constants/restaurant_filters.dart';
import 'package:vn_travel_companion/core/constants/transport_options.dart';

class TripTransportsModal extends StatefulWidget {
  final List<TransportOption> currentTransports;
  final ValueChanged<List<TransportOption>> onTransportsChanged;
  const TripTransportsModal(
      {super.key,
      required this.currentTransports,
      required this.onTransportsChanged});

  @override
  State<TripTransportsModal> createState() => _TripTransportsModalState();
}

class _TripTransportsModalState extends State<TripTransportsModal> {
  List<TransportOption> _seletedTransports = [];
  @override
  void initState() {
    super.initState();
    _seletedTransports = widget.currentTransports;
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
                "Dịch vụ",
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
                ...transportOptions.map(
                  (transport) {
                    return CheckboxListTile(
                      value: _seletedTransports.contains(transport),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 20),
                      controlAffinity: ListTileControlAffinity.trailing,
                      title: Row(
                        children: [
                          transport.badge,
                          const SizedBox(
                            width: 20,
                          ),
                          Text(
                            transport.label,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      onChanged: (value) {
                        setState(() {
                          if (value!) {
                            _seletedTransports.add(transport);
                          } else {
                            _seletedTransports.remove(transport);
                          }
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
                    _seletedTransports = [];
                  });
                },
                child: const Text("Hủy",
                    style: TextStyle(decoration: TextDecoration.underline))),
            ElevatedButton(
              onPressed: () {
                widget.onTransportsChanged(_seletedTransports);
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
