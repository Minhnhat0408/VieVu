import 'package:flutter/material.dart';

String convertTypeIdToString(int? typeId) {
  switch (typeId) {
    case 1:
      return 'Đồ ăn & đồ uống';
    case 2:
      return 'Địa điểm tham quan';
    case 0:
      return 'Điểm đến du lịch';
    case 4:
      return 'Địa điểm lưu trú';
    case 5:
      return 'Sự kiện & giải trí';
    default:
      return 'Tất cả';
  }
}

Icon convertTypeIdToIcons(int? typeId, double size) {
  switch (typeId) {
    case 1:
      return Icon(
        size: size,
        Icons.restaurant,
        color: Colors.orangeAccent,
      );
    case 2:
      return Icon(
        size: size,
        Icons.attractions,
        color: Colors.greenAccent,
      );
    case 0:
      return Icon(
        size: size,
        Icons.location_pin,
      );
    case 4:
      return Icon(
        size: size,
        Icons.hotel,
        color: Colors.blueAccent,
      );
    case 5:
      return Icon(
        size: size,
        Icons.liquor,
        color: Colors.redAccent,
      );
    default:
      return Icon(
        size: size,
        Icons.location_pin,
      );
  }
}
