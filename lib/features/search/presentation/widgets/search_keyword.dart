import 'package:flutter/material.dart';

class SearchKeyword extends StatelessWidget {
  final String keyword;
  final bool ticketBox;
  const SearchKeyword({
    super.key,
    required this.keyword,
    this.ticketBox = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed('/search-results', arguments: {
          'keyword': keyword,
          'ticketBox': ticketBox,
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20),
        child: Row(
          children: [
            Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surfaceBright,
                    width: 2.0,
                  ),
                ),
                width: 90,
                height: 90,
                alignment: Alignment.center,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: const Icon(
                  Icons.search,
                  size: 40,
                )),
            const SizedBox(width: 20),
            Expanded(
              // Ensure this widget allows text to take available space
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticketBox
                          ? 'Xem tất cả kết quả TicketBox cho'
                          : 'Xem tất cả kết quả cho',
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '"$keyword"',
                      softWrap: true, // Wrap the address to the next line
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
