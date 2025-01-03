import 'package:flutter/material.dart';
import 'package:vn_travel_companion/core/constants/restaurant_filters.dart';

class RestaurantOpenTimeModal extends StatefulWidget {
  final List<String> currentServices;
  final ValueChanged<List<String>> onServicesChanged;
  const RestaurantOpenTimeModal(
      {super.key,
      required this.currentServices,
      required this.onServicesChanged});

  @override
  State<RestaurantOpenTimeModal> createState() =>
      _RestaurantOpenTimeModalState();
}

class _RestaurantOpenTimeModalState extends State<RestaurantOpenTimeModal> {
  List<String> _seletedServices = [];
  @override
  void initState() {
    super.initState();
    _seletedServices = widget.currentServices;
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
                "Giờ mở cửa",
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
                ...restaurantTimeSlotsMap.entries.map(
                  (service) {
                    return CheckboxListTile(
                      value: _seletedServices.contains(service.key),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 20),
                      controlAffinity: ListTileControlAffinity.trailing,
                      title: Text(
                        service.key,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onChanged: (value) {
                        setState(() {
                          if (value!) {
                            _seletedServices.add(service.key);
                          } else {
                            _seletedServices.remove(service.key);
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
                    _seletedServices = [];
                  });
                },
                child: const Text("Hủy",
                    style: TextStyle(decoration: TextDecoration.underline))),
            ElevatedButton(
              onPressed: () {
                widget.onServicesChanged(_seletedServices);
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
