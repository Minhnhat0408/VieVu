import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

Future<dynamic> displayModal(
    BuildContext context, Widget child, double? height, bool expand) {
  return showBarModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    useRootNavigator: true,
    enableDrag: true,
    topControl: Container(
      width: 80,
      height: 5,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(5),
      ),
    ),
    expand: expand,
    builder: (context) =>
        height != null ? SizedBox(height: height, child: child) : child,
  );
}

void displayFullScreenModal(BuildContext context, Widget child) {
  showGeneralDialog(
    context: context,
    pageBuilder: (context, animation1, animation2) {
      return child;
    },
    transitionBuilder: (context, animation1, animation2, child) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.2, end: 1.0).animate(CurvedAnimation(
          parent: animation1,
          curve: const Interval(
            0.2,
            1.0,
            curve: Curves.easeInOut,
          ),
        )),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.2, end: 1.0).animate(CurvedAnimation(
            parent: animation1,
            curve: const Interval(
              0.2,
              1.0,
              curve: Curves.easeInOut,
            ),
          )),
          child: Dialog.fullscreen(
            child: child,
          ),
        ),
      );
    },
    barrierDismissible: true,
    barrierLabel: '',
    transitionDuration: const Duration(milliseconds: 400),
  );
}
