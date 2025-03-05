import 'package:flutter/material.dart';

class AddItineraryOptionsModal extends StatelessWidget {
  const AddItineraryOptionsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(
        height: 10,
      ),
      InkWell(
        onTap: () {
          Navigator.pop(context, 'add_new');
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                'Thêm mục mới',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
      Divider(
        thickness: 1,
        color: Theme.of(context).colorScheme.primary,
      ),
      InkWell(
        onTap: () {
          Navigator.pop(context, 'select_saved');
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                'Chọn từ danh sách',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(
        height: 10,
      ),
    ]);
  }
}
