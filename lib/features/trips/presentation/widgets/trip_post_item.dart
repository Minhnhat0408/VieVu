import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class TripPostItem extends StatefulWidget {
  const TripPostItem({super.key});

  @override
  State<TripPostItem> createState() => _TripPostItemState();
}

class _TripPostItemState extends State<TripPostItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.asset(
                'assets/images/trip_placeholder.avif',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 14,
                left: 14,
                child: Row(
                  children: [
                    Badge(
                      label: const Icon(
                        Icons.flight,
                        size: 20,
                      ),
                      alignment: Alignment.center,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      padding: const EdgeInsets.all(5),
                    ),
                    const SizedBox(width: 4),
                    Badge(
                      label: const Icon(
                        Icons.train,
                        size: 20,
                      ),
                      alignment: Alignment.center,
                      backgroundColor:
                          Theme.of(context).colorScheme.tertiaryContainer,
                      padding: const EdgeInsets.all(5),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 14,
                left: 14,
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage(
                        'assets/images/intro2.jpg',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Nguyễn Văn A",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontSize: 14),
                        ),
                        Text(
                          timeago.format(DateTime.now(), locale: 'vi'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color.fromARGB(255, 215, 215, 215),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              Positioned(
                bottom: 14,
                right: 14,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'Lên kế hoạch',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chuyến đi Đầu năm',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 20,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Hà Nội - Nha Trang',
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: Icon(
                            Icons.calendar_month,
                            size: 18,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '10/10/2021 - 20/10/2021',
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: Icon(
                            Icons.person,
                            size: 18,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '3/10 thành viên',
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: Icon(
                            Icons.favorite_outline,
                            size: 18,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '3 mục đã lưu',
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                        ),
                        onPressed: () {},
                        icon: const Icon(Icons.bookmark)),
                    IconButton(
                        onPressed: () {},
                        style: IconButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.tertiaryContainer,
                        ),
                        icon: const Icon(Icons.travel_explore)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
