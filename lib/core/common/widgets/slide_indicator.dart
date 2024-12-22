import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SlideIndicator extends StatelessWidget {
  final int activeIndex;
  final int size;
  final int width;
  const SlideIndicator({
    super.key,
    required this.activeIndex,
    required this.size,
    this.width = 40,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSmoothIndicator(
      activeIndex: activeIndex,
      count: size,
      effect: SlideEffect(
        activeDotColor: Theme.of(context).colorScheme.primaryContainer,
        dotHeight: 5,
        dotWidth: width.toDouble(),
        spacing: width.toDouble() / 4,
      ),
    );
  }
}
