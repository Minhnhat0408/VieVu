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
        color: Colors.black,
        Icons.flight,
        size: 20,
      ),
      alignment: Alignment.center,
      backgroundColor: Color.fromARGB(255, 112, 165, 255),
      padding: EdgeInsets.all(5),
    ),
  ),
  TransportOption(
    label: 'Tàu hỏa',
    value: 'train',
    badge: const Badge(
      label: Icon(
        color: Colors.black,
        Icons.train,
        size: 20,
      ),
      alignment: Alignment.center,
      backgroundColor: Color.fromARGB(255, 255, 229, 133),
      padding: EdgeInsets.all(5),
    ),
  ),
  TransportOption(
    label: 'Thuyền',
    value: 'boat',
    badge: const Badge(
      label: Icon(
        color: Colors.black,
        Icons.sailing,
        size: 20,
      ),
      alignment: Alignment.center,
      backgroundColor: Color.fromARGB(255, 120, 255, 210),
      padding: EdgeInsets.all(5),
    ),
  ),
  TransportOption(
    label: 'Xe hơi',
    value: 'car',
    badge: const Badge(
      label: Icon(
        color: Colors.black,
        Icons.directions_car,
        size: 20,
      ),
      alignment: Alignment.center,
      backgroundColor: Color.fromARGB(255, 255, 138, 138),
      padding: EdgeInsets.all(5),
    ),
  ),
  TransportOption(
    label: 'Xe máy',
    value: 'motorbike',
    badge: const Badge(
      label: Icon(
        color: Colors.black,
        Icons.motorcycle,
        size: 20,
      ),
      alignment: Alignment.center,
      backgroundColor: Color.fromARGB(255, 216, 255, 133),
      padding: EdgeInsets.all(5),
    ),
  ),
  TransportOption(
    label: 'Đi bộ',
    value: 'walk',
    badge: const Badge(
      label: Icon(
        color: Colors.black,
        Icons.directions_walk,
        size: 20,
      ),
      alignment: Alignment.center,
      backgroundColor: Color.fromARGB(255, 255, 167, 221),
      padding: EdgeInsets.all(5),
    ),
  ),
];
