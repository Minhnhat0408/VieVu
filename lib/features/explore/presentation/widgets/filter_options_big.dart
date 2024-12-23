import 'package:flutter/material.dart';

class FilterOptionsBig extends StatelessWidget {
  final List<String> options;
  final String selectedOption;
  final Function(String) onOptionSelected;
  final bool isFiltering;
  final double outerPadding;
  const FilterOptionsBig({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onOptionSelected,
    required this.isFiltering,
    this.outerPadding = 20,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        itemBuilder: (context, index) {
          final filter = options[index];
          final isSelected = filter == selectedOption;
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? outerPadding : 4.0,
              right: index == options.length - 1 ? outerPadding : 4.0,
            ),
            child: OutlinedButton(
              onPressed: isFiltering
                  ? null // Disable button when state is SearchLoading
                  : () => onOptionSelected(
                      filter), // Enable button when state is not SearchLoading
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    width: 2,
                    color: isFiltering
                        ? Colors.grey
                        : Theme.of(context).colorScheme.primary),
                backgroundColor:
                    isSelected ? Theme.of(context).colorScheme.primary : null,
                // Add disabled style
                foregroundColor: isFiltering
                    ? Colors.grey // Change text color to grey when disabled
                    : null,
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : isFiltering
                          ? Colors
                              .grey // Change text color to grey when disabled
                          : Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
