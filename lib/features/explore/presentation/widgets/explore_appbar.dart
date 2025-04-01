import 'dart:ui';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vievu/features/explore/presentation/widgets/explore_search_button.dart';

class ExploreAppbar extends StatefulWidget {
  const ExploreAppbar({super.key});

  @override
  State<ExploreAppbar> createState() => _ExploreAppbarState();
}

class _ExploreAppbarState extends State<ExploreAppbar> {
  final List<String> title = [
    'Khám phá vẻ đẹp Việt Nam',
    'Đi du lịch cùng mọi người',
    'Lên kế hoạch cho chuyến đi',
    'Khám phá vẻ đẹp Việt Nam',
  ];

  double calculatePadding(double appBarHeight) {
    const double minHeight = 121.0; // Threshold height for minimum padding
    const double maxHeight = 400.0; // Approximate max expanded height
    const double minPadding = 16.0; // Minimum bottom padding
    const double maxPadding = 240.0; // Maximum bottom padding

    // Clamp appBarHeight to the valid range
    appBarHeight = appBarHeight.clamp(minHeight, maxHeight);

    // Interpolate padding
    double t = (appBarHeight - minHeight) / (maxHeight - minHeight);
    return maxPadding * t + minPadding * (1 - t);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Calculate the current height of the FlexibleSpace
        double appBarHeight = constraints.biggest.height;

        return FlexibleSpaceBar(
          titlePadding: EdgeInsets.only(
            bottom: calculatePadding(appBarHeight),
            left: 20,
            right: 20,
          ),
          title: const Hero(
            tag: 'exploreSearch',
            child: ExploreSearchButton(showNotification: false),
          ),
          expandedTitleScale: 1,
          background: Stack(
            fit: StackFit.expand,
            children: [
              ClipPath(
                clipper: CurvedBottomClipper(curveOffset: 30),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/intro1.jpg',
                      fit: BoxFit.cover,
                    ),
                    Positioned.fill(
                      child: Container(color: Colors.black.withOpacity(0.3)),
                    ),
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                        child: const SizedBox(),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 8,
                      left: 20,
                      right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Khám phá',
                          textAlign: TextAlign.start,
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge!
                              .copyWith(color: const Color(0xFFE8E9DE))),
                      const SizedBox(height: 90),
                      Expanded(
                        child: AnimatedTextKit(
                          animatedTexts: List.generate(
                            title.length,
                            (index) => TyperAnimatedText(
                              title[index],
                              textAlign: TextAlign.center,
                              speed: const Duration(milliseconds: 60),
                              textStyle: GoogleFonts.dancingScript(
                                  fontSize: 56,
                                  color: const Color(0xFFE8E9DE),
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                          pause: const Duration(milliseconds: 2000),
                          displayFullTextOnTap: true,
                          totalRepeatCount: 1,
                          stopPauseOnTap: true,
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        );
      },
    );
  }
}

class CurvedBottomClipper extends CustomClipper<Path> {
  final double curveOffset;

  CurvedBottomClipper({this.curveOffset = 50});

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - curveOffset);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - curveOffset);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
