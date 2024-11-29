import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:vn_travel_companion/features/auth/presentation/pages/log_in.dart';

class IntroductionPage extends StatefulWidget {
  static route() {
    return MaterialPageRoute(builder: (context) => const IntroductionPage());
  }

  const IntroductionPage({super.key});

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  int activeIndex = 0;
  final imgList = [
    "assets/images/intro1.jpg",
    "assets/images/intro2.jpg",
    "assets/images/intro3.webp",
  ];

  final imgDesc = [
    {
      "headLine": "Khám phá vẻ đẹp Việt Nam",
      "subHead": "Thỏa sức khám phá vẻ đẹp thiên nhiên đất trời",
    },
    {
      "headLine": "Du lịch cùng mọi người",
      "subHead": "Bắt đầu tìm kiếm bạn đồng hành ngay hôm nay",
    },
    {
      "headLine": "Lên kế hoạch cho chuyến đi",
      "subHead": "Hãy lên kế hoạch cho chuyến đi của bạn ngay hôm nay",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          CarouselSlider.builder(
            itemCount: imgList.length,
            itemBuilder: (context, index, realIndex) {
              return cardImage(index, context);
            },
            options: CarouselOptions(
              height: double.infinity,
              viewportFraction: 1,
              initialPage: 0,
              reverse: false,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayCurve: Curves.fastOutSlowIn,
              onPageChanged: (index, reason) =>
                  setState(() => activeIndex = index),
            ),
          ),

          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment
                    .spaceBetween, // This will space out the children
                children: [
                  slideIndicator(context),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, LogInPage.route());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "Khám phá",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget cardImage(int index, context) => SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                imgList[index],
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              top: MediaQuery.of(context).size.height * 1 / 4,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                // color: Colors.black.withOpacity(1),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 48.0, bottom: 24),
                        child: Text(
                          imgDesc[index]["headLine"] ?? "",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        imgDesc[index]["subHead"] ?? "",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget slideIndicator(context) => AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: imgList.length,
        effect: SlideEffect(
          activeDotColor: Theme.of(context).colorScheme.primaryContainer,
          dotHeight: 5,
          dotWidth: 40,
          spacing: 10,
        ),
      );
}
