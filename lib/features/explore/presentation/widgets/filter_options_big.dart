
import 'package:flutter/material.dart';

class FilterOptionsBig extends StatefulWidget {
  final List<String> options;
  final String selectedOption;
  final Function(String) onOptionSelected; // Allow null for deselection
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
  State<FilterOptionsBig> createState() => _FilterOptionsBigState();
}

class _FilterOptionsBigState extends State<FilterOptionsBig> {
  List<String> options = [];
  String? topItem;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    options = List.from(widget.options);
    topItem = widget.selectedOption.isNotEmpty ? widget.selectedOption : null;
  }

  void toggleSelection(String item) {
    setState(() {
      if (widget.selectedOption == "Tìm kiếm gần đây") {
        return;
      }
      if (topItem == item) {
        // If clicking again, unselect and restore order
        topItem = null;
        options = List.from(widget.options);
        widget.onOptionSelected('');
      } else {
        // Move selected item to top
        topItem = item;
        widget.onOptionSelected(item);
      }
    });

    // Scroll to the start smoothly when selecting
    if (topItem != null) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    options.clear();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        children: [
          if (topItem != null) _buildButton(topItem!, isTop: true),
          ...options
              .where((item) => item != topItem)
              .map((item) => _buildButton(item)),
        ],
      ),
    );
  }

  Widget _buildButton(String filter, {bool isTop = false}) {
    final isSelected = filter == topItem;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => SizeTransition(
        sizeFactor: animation,
        child: child,
      ),
      child: Padding(
        key: ValueKey(filter),
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: OutlinedButton(
          onPressed: widget.isFiltering ? null : () => toggleSelection(filter),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
                width: 2,
                color: widget.isFiltering
                    ? Colors.grey
                    : Theme.of(context).colorScheme.primary),
            backgroundColor:
                isSelected ? Theme.of(context).colorScheme.primary : null,
            foregroundColor: widget.isFiltering ? Colors.grey : null,
          ),
          child: Text(
            filter,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : widget.isFiltering
                      ? Colors.grey
                      : Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
