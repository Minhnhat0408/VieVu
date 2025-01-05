import 'package:flutter/material.dart';

class HotelRoomInfoModal extends StatefulWidget {
  final int roomQuantity;
  final int adultCount;
  final int childCount;
  final ValueChanged<List> onRoomInfoChanged;
  const HotelRoomInfoModal(
      {super.key,
      required this.roomQuantity,
      required this.adultCount,
      required this.childCount,
      required this.onRoomInfoChanged});

  @override
  State<HotelRoomInfoModal> createState() => _HotelRoomInfoModalState();
}

class _HotelRoomInfoModalState extends State<HotelRoomInfoModal> {
  late int _currentRoomQuantity;
  late int _currentAdultCount;
  late int _currentChildCount;

  @override
  void initState() {
    super.initState();
    _currentRoomQuantity = widget.roomQuantity;
    _currentAdultCount = widget.adultCount;
    _currentChildCount = widget.childCount;
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
                "Chọn thông tin phòng",
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Room quantity row of title and - number +
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Số phòng",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (_currentRoomQuantity > 1) {
                              _currentRoomQuantity--;
                            }
                          });
                        },
                      ),
                      Text("$_currentRoomQuantity",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            _currentRoomQuantity++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              // Adult count row of title and - number +
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Người lớn",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (_currentAdultCount > 1) {
                              _currentAdultCount--;
                            }
                          });
                        },
                      ),
                      Text("$_currentAdultCount",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            _currentAdultCount++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Trẻ em",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (_currentChildCount > 0) {
                              _currentChildCount--;
                            }
                          });
                        },
                      ),
                      Text("$_currentChildCount",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            _currentChildCount++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
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
                    _currentRoomQuantity = widget.roomQuantity;
                    _currentAdultCount = widget.adultCount;
                    _currentChildCount = widget.childCount;
                  });
                },
                child: const Text("Hủy",
                    style: TextStyle(decoration: TextDecoration.underline))),
            ElevatedButton(
              onPressed: () {
                widget.onRoomInfoChanged([
                  _currentRoomQuantity,
                  _currentAdultCount,
                  _currentChildCount
                ]);
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
