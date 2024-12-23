import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ImageCarouselPage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  const ImageCarouselPage(
      {super.key, required this.images, this.initialIndex = 0});

  @override
  State<ImageCarouselPage> createState() => _ImageCarouselPageState();
}

class _ImageCarouselPageState extends State<ImageCarouselPage> {
  int _currentIndex = 0;
  CarouselSliderController buttonCarouselController =
      CarouselSliderController();
  final ScrollController _listViewController = ScrollController();
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: CarouselSlider.builder(
              itemCount: widget.images.length,
              carouselController: buttonCarouselController,
              options: CarouselOptions(
                height: double.infinity,
                viewportFraction: 1.0,
                initialPage: _currentIndex,
                enlargeCenterPage: false,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) {
                  // check if the box of index is still in view
                  if (index * 108.0 < _listViewController.offset ||
                      index * 108.0 > _listViewController.offset + 108.0 * 3) {
                    _listViewController.animateTo(
                      index * 108.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }

                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
              itemBuilder: (context, index, realIndex) {
                return CachedNetworkImage(
                  imageUrl: widget.images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error, color: Colors.white),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              controller: _listViewController,
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    buttonCarouselController.animateToPage(index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          border: _currentIndex == index
                              ? Border.all(
                                  color: Colors.white,
                                  width: 4,
                                )
                              : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: widget.images[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            width: 100,
                            height: 100,
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Ảnh ${_currentIndex + 1} trên ${widget.images.length}",
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _listViewController.dispose();
    super.dispose();
  }
}
