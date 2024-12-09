import 'dart:developer';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';

class ExplorePage extends StatefulWidget {
  static route() {
    return MaterialPageRoute(builder: (context) => const ExplorePage());
  }

  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final List<String> title = [
    'Khám phá vẻ đẹp Việt Nam',
    'Đi du lịch cùng mọi người',
    'Lên kế hoạch cho chuyến đi',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            leading: null,
            scrolledUnderElevation: 0,
            collapsedHeight: 70,
            foregroundColor: Theme.of(context).colorScheme.surface,
            backgroundColor: Theme.of(context).colorScheme.surface,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                // Calculate the current height of the FlexibleSpace
                double appBarHeight = constraints.biggest.height;
                bool show = appBarHeight < 121;

                return FlexibleSpaceBar(
                  titlePadding:
                      const EdgeInsets.only(bottom: 16.0, left: 20, right: 20),
                  title: SearchBar(
                      constraints: const BoxConstraints(
                        maxHeight: 100,
                        minHeight: 50,
                      ),
                      leading: const Icon(Icons.search),
                      padding: const WidgetStatePropertyAll<EdgeInsets>(
                          EdgeInsets.symmetric(horizontal: 16)),
                      hintText: 'Tìm kiếm địa điểm du lịch...',
                      trailing: <Widget>[
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 500),
                          opacity: show ? 1.0 : 0.0,
                          child: IconButton(
                            onPressed: show ? () {} : null,
                            icon: const Icon(Icons.notifications_none),
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHigh,
                            ),
                          ),
                        )
                      ]),
                  collapseMode: CollapseMode.pin,
                  expandedTitleScale: 1,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/intro1.jpg',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned.fill(
                          child:
                              Container(color: Colors.black.withOpacity(0.3))),
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                          blendMode: BlendMode.srcOver,
                          child: const SizedBox(),
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top + 8,
                              left: 16,
                              right: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Khám phá',
                                      textAlign: TextAlign.start,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineLarge!
                                          .copyWith(
                                              color: const Color(0xFFE8E9DE))),
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.notifications_none),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHigh,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const SizedBox(height: 50),
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
                                  repeatForever: true,
                                  stopPauseOnTap: true,
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                );
              },
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('Destination $index'),
                  subtitle: Text('Description for destination $index'),
                  leading: const Icon(Icons.place),
                  onTap: () {},
                ),
              ),
              childCount: 20, // Example list item count
            ),
          ),
        ],
      ),
    );
  }
}
