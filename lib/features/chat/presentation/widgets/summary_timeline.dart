import 'package:flutter/material.dart';
import 'package:vievu/core/utils/open_url.dart';
import 'package:intl/intl.dart' as intl;

class SummaryTimeline extends StatelessWidget {
  final Map<String, dynamic> item;
  const SummaryTimeline({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 4, bottom: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Căn theo chiều dọc
        children: [
          // Nội dung chính
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['place'],
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                if (item['latitude'] != null && item['longitude'] != null)
                  GestureDetector(
                    onTap: () {
                      openDeepLink(
                          "https://www.google.com/maps?q=${item['latitude']},${item['longitude']}");
                    },
                    child: Row(
                      children: [
                        Image.asset('assets/icons/gg-pin.png',
                            width: 20, height: 20),
                        const SizedBox(width: 10),
                        Text(
                          "Xem trên Google Maps",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.timer_sharp, size: 20, color: Colors.cyan[200]),
                    const SizedBox(width: 10),
                    Text(
                      intl.DateFormat('HH:mm')
                          .format(DateTime.parse(item['time'])),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.notes, size: 20, color: Colors.amber[200]),
                    const SizedBox(width: 10),
                    Expanded(
                      // Đổi từ Flexible -> Expanded để tránh lỗi
                      child: Text(
                        item['note'] ?? "Chưa có ghi chú",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),

          // Mũi tên bên phải
          const SizedBox(width: 10),
          IconButton(
              onPressed: () {
                Navigator.of(context).pop(item['metaData']['message_id']);
              },
              icon: const Icon(Icons.arrow_forward_ios,
                  size: 20, color: Colors.grey)),
        ],
      ),
    );
  }
}
