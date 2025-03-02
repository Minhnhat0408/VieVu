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

Future displayFullScreenModal(BuildContext context, Widget child) {
  return showGeneralDialog(
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

void showTopDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true, // Close when tapping outside
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: const Duration(milliseconds: 300), // Animation duration
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.topCenter,
        child: Material(
          color: Colors.transparent,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -1), // Start from above
              end: const Offset(0, 0), // Slide to position
            ).animate(animation),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(top: 50), // Adjust top position
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 5)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Top Slide Modal",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text("This modal slides down from the top."),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1), // Slide from top
          end: const Offset(0, 0), // Stop at original position
        ).animate(animation),
        child: child,
      );
    },
  );
}
