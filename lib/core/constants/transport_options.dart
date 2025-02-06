import 'package:flutter/material.dart';

class TransportOption {
  final String label;
  final String value;
  final Badge badge;

  TransportOption({
    required this.label,
    required this.value,
    required this.badge,
  });
}

final transportOptions = [
  TransportOption(
    label: 'Máy bay',
    value: 'plane',
    badge: const Badge(
      label: Icon(
        Icons.flight,
        size: 20,
      ),
      alignment: Alignment.center,
      backgroundColor: Colors.blueAccent,
      padding: EdgeInsets.all(5),
    ),
  ),
  TransportOption(
    label: 'Tàu hỏa',
    value: 'train',
    badge: const Badge(
      label: Icon(
        Icons.train,
        size: 20,
      ),
      alignment: Alignment.center,
      backgroundColor: Colors.amberAccent,
      padding: EdgeInsets.all(5),
    ),
  ),
  TransportOption(
    label: 'Thuyền',
    value: 'boat',
    badge: const Badge(
      label: Icon(
        Icons.sailing,
        size: 20,
      ),
      alignment: Alignment.center,
      backgroundColor: Colors.amberAccent,
      padding: EdgeInsets.all(5),
    ),
  ),
  TransportOption(
    label: 'Xe hơi',
    value: 'car',
    badge: const Badge(
      label: Icon(
        Icons.directions_car,
        size: 20,
      ),
      alignment: Alignment.center,
      backgroundColor: Colors.redAccent,
      padding: EdgeInsets.all(5),
    ),
  ),
  TransportOption(
    label: 'Xe máy',
    value: 'motorbike',
    badge: const Badge(
      label: Icon(
        Icons.motorcycle,
        size: 20,
      ),
      alignment: Alignment.center,
      backgroundColor: Colors.limeAccent,
      padding: EdgeInsets.all(5),
    ),
  ),
  TransportOption(
    label: 'Đi bộ',
    value: 'walk',
    badge: const Badge(
      label: Icon(
        Icons.directions_walk,
        size: 20,
      ),
      alignment: Alignment.center,
      backgroundColor: Colors.tealAccent,
      padding: EdgeInsets.all(5),
    ),
  ),
];
