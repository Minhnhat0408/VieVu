List<TripStatus> tripStatusList = [
  TripStatus(label: 'Lên kế hoạch', value: 'planning'),
  TripStatus(label: 'Đang diễn ra', value: 'ongoing'),
  TripStatus(label: 'Đã hoàn thành', value: 'completed'),
  TripStatus(label: 'Đã hủy', value: 'cancelled'),
];

class TripStatus {
  final String label;
  final String value;

  TripStatus({required this.label, required this.value});
}
