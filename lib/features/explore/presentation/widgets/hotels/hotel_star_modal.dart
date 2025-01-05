import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class HotelStarModal extends StatefulWidget {
  final int? currentRating;
  final ValueChanged<int?> onRatingChanged;
  const HotelStarModal(
      {super.key, required this.currentRating, required this.onRatingChanged});

  @override
  State<HotelStarModal> createState() => _HotelStarModalState();
}

class _HotelStarModalState extends State<HotelStarModal> {
  late int? _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.currentRating;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                width: 30,
              ),
              const Text(
                "Chọn đánh giá",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        Divider(
          thickness: 1,
          color: Theme.of(context).colorScheme.primary,
        ),
        ...[5, 4, 3, 2].map(
          (rating) {
            return RadioListTile(
              value: rating,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              groupValue: _currentRating,
              controlAffinity: ListTileControlAffinity.trailing,
              title: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20)),
                    child: RatingBarIndicator(
                      rating: rating.toDouble(),
                      itemSize: 20,
                      direction: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, _) => const Icon(Icons.star,
                          color: Color.fromARGB(255, 255, 232, 25)),
                    ),
                  ),
                ],
              ),
              onChanged: (value) {
                setState(() {
                  _currentRating = value;
                });
              },
            );
          },
        ),
        Divider(
          thickness: 1,
          color: Theme.of(context).colorScheme.primary,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
                onPressed: () {
                  setState(() {
                    _currentRating = null;
                  });
                },
                child: const Text("Hủy",
                    style: TextStyle(decoration: TextDecoration.underline))),
            ElevatedButton(
              onPressed: () {
                widget.onRatingChanged(_currentRating);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: const Text("Áp dụng"),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
