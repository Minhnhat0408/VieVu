import 'package:flutter/material.dart';

class TitleSection extends StatelessWidget {
  const TitleSection({
    super.key,
    required this.name,
    required this.location,
  });

  final String name;
  final String location;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.tertiary),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Row(
          children: [
            Expanded(
              /*1*/
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  /*2*/
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    location,
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            /*3*/
            Container(
              decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).colorScheme.tertiary),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
              margin: const EdgeInsets.only(right: 12, left: 24),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Icon(
                  Icons.star,
                  color: Colors.red[500],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).colorScheme.tertiary),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
              child: const Padding(
                padding: EdgeInsets.all(18.0),
                child: Text('41'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
