import 'package:flutter/material.dart';

class OpenTimeDisplay extends StatelessWidget {
  final List<dynamic> openTimeRules;

  const OpenTimeDisplay({super.key, required this.openTimeRules});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: openTimeRules.map((rule) {
        final dateDesc = rule['dateDesc'] ?? 'Không xác định';
        final timeRules = rule['openTimeRuleInfoType'] as List<dynamic>? ?? [];
        final isActive = rule['isActivityCurrentTime'] ?? false;

        return Card(
          margin: const EdgeInsets.all(0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateDesc,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 8),
                ...timeRules.map((timeRule) {
                  final timeDesc = timeRule['timeDesc'];
                  final description =
                      timeRule['description'] ?? 'Không có mô tả';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Theme.of(context).colorScheme.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            timeDesc != null
                                ? '$timeDesc: $description'
                                : description,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
