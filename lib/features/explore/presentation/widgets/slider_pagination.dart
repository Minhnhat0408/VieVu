import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:vn_travel_companion/core/common/widgets/slide_indicator.dart';

class SliderPagination extends StatefulWidget {
  final List<String> imgList;

  const SliderPagination({
    super.key,
    required this.imgList,
  });

  @override
  State<SliderPagination> createState() => _SliderPaginationState();
}

class _SliderPaginationState extends State<SliderPagination> {
  int activeIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CarouselSlider.builder(
          itemCount: widget.imgList.length,
          itemBuilder: (context, index, realIndex) {
            return CachedNetworkImage(
              imageUrl: widget.imgList[index],
              fadeInDuration: const Duration(milliseconds: 200),
              filterQuality: FilterQuality.high,
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.5,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            );
          },
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height * 0.5,
            viewportFraction: 1,
            initialPage: 0,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayCurve: Curves.fastOutSlowIn,
            onPageChanged: (index, reason) => setState(() {
              activeIndex = index;
            }),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: SlideIndicator(
              activeIndex: activeIndex,
              size: widget.imgList.length,
              width: 20,
            ),
          ),
        ),
      ],
    );
  }
}
