import 'package:flutter/material.dart';

class PrefOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Function onTap;
  final bool? checkBox;
  const PrefOption(
      {super.key,
      required this.title,
      required this.isSelected,
      required this.onTap,
      this.checkBox = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextButton(
        onPressed: () => onTap(),
        style: TextButton.styleFrom(
          backgroundColor: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHigh,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 16, right: 6, top: 8, bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        iconAlignment: IconAlignment.end,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Checkbox(
              value: isSelected,
              onChanged: (value) {
                onTap();
              },
            )
          ],
        ),
      ),
    );
  }
}
