String convertTypeIdToString(int typeId) {
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
