import 'dart:ffi';
import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroductionPage extends StatefulWidget {
  IntroductionPage({super.key});

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  int activeIndex = 0;
  final imgList = [
    "https://instagram.fhan2-4.fna.fbcdn.net/v/t39.30808-6/458747528_18069344863603805_8003420746203458630_n.jpg?stp=dst-jpg_e35_p750x750_sh0.08&efg=eyJ2ZW5jb2RlX3RhZyI6ImltYWdlX3VybGdlbi4xNDQweDE4MDAuc2RyLmYzMDgwOC5kZWZhdWx0X2ltYWdlIn0&_nc_ht=instagram.fhan2-4.fna.fbcdn.net&_nc_cat=105&_nc_ohc=_usLc6igitwQ7kNvgGWGdZ1&_nc_gid=e82fde278a3d415786de6335ed40fa95&edm=ALQROFkAAAAA&ccb=7-5&ig_cache_key=MzQ1MTE2MDQ1MDUxMzUxMjg1MA%3D%3D.3-ccb7-5&oh=00_AYBJzBhO8r_5s9MZaZu3Sfc4EbOfNuG1P_iFGenBZqDMkg&oe=674661BE&_nc_sid=fc8dfb",
    "https://static.vinwonders.com/production/vietnam-travel-2.jpg",
    "https://www.traveloffpath.com/wp-content/uploads/2023/01/Asian-Woman-Wearing-A-Traditional-Attire-As-She-Stands-At-The-Tip-Of-A-Long-Tail-Boat-Crossing-A-Lake-In-Vietnam-Southeast-Asia.jpg.webp"
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
                  slideIndicator(),
                  ElevatedButton(
                    onPressed: () {
                      print("Button Pressed");
                    },
                    style: ElevatedButtonTheme.of(context).style,
                    child: const Text("Click Me"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget cardImage(int index, context) => Container(
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
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

  Widget slideIndicator() => AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: imgList.length,
        effect: const SlideEffect(
          dotHeight: 5,
          dotWidth: 40,
          spacing: 10,
        ),
      );
}
