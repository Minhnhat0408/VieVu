import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

void displayModal(
    BuildContext context, Widget child, double? height, bool expand) {
  showBarModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    useRootNavigator: true,
    enableDrag: true,
    topControl: Container(
      width: 40,
      height: 5,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(5),
      ),
    ),
    expand: expand,
    builder: (context) =>
        height != null ? SizedBox(height: height, child: child) : child,
  );
}
