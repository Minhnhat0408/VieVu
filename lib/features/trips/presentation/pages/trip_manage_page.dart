import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vn_travel_companion/core/utils/display_modal.dart';

class TripManagePage extends StatefulWidget {
  const TripManagePage({super.key});

  @override
  State<TripManagePage> createState() => _TripManagePageState();
}

class _TripManagePageState extends State<TripManagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chuyến đi của bạn'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            Text(
              'Bắt đầu tạo chuyến đi đầu tiên của bạn',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Tự xây dựng các chuyến đi để bắt đầu hành trình của bạn với các thành viên khác.',
              style: TextStyle(
                // italics
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Badge(
                  label:
                      const FaIcon(FontAwesomeIcons.heartCirclePlus, size: 20),
                  alignment: Alignment.center,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  padding: const EdgeInsets.all(10),
                ),
                const SizedBox(width: 16),
                const Flexible(
                  // Use Flexible or Expanded here

                  child: Text(
                    'Lưu các địa điểm, nhà hàng, khách sạn bạn quan tâm',
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Badge(
                  label:
                      const FaIcon(FontAwesomeIcons.mapLocationDot, size: 20),
                  alignment: Alignment.center,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  padding: const EdgeInsets.all(10),
                ),
                const SizedBox(width: 16),
                const Flexible(
                  // Use Flexible or Expanded here

                  child: Text(
                    'Xem bản đồ trực quan của chuyến đi bạn đã lên kế hoạch',
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Badge(
                  label: const FaIcon(FontAwesomeIcons.clipboardList, size: 20),
                  alignment: Alignment.center,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  padding: const EdgeInsets.all(10),
                ),
                const SizedBox(width: 16),
                const Flexible(
                  // Use Flexible or Expanded here

                  child: Text(
                    'Lên lịch trình và danh sách công việc cần làm dễ dàng hơn',
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Badge(
                  label: const FaIcon(FontAwesomeIcons.solidComments, size: 20),
                  alignment: Alignment.center,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  padding: const EdgeInsets.all(10),
                ),
                const SizedBox(width: 16),
                const Flexible(
                  // Use Flexible or Expanded here

                  child: Text(
                    'Cùng thảo luận với các thành viên khác về chuyến đi để lên kế hoạch tốt nhất',
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Badge(
                  label: const FaIcon(FontAwesomeIcons.peopleGroup, size: 20),
                  alignment: Alignment.center,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  padding: const EdgeInsets.all(10),
                ),
                const SizedBox(width: 16),
                const Flexible(
                  // Use Flexible or Expanded here

                  child: Text(
                    'Chia sẻ trải nghiệm và chuyến đi của bạn với cộng đồng',
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  displayModal(
                      context,
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Padding(
                            padding:
                                EdgeInsets.only(left: 20.0, right: 20, top: 20),
                            child: Text(
                              "Tạo chuyến đi",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 20),
                            child: TextField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Tên chuyến đi',
                                hintText: 'Ví dụ: Chuyến đi Hội An 2025',
                              ),
                            ),
                          ),
                          // Flexible(
                          //   child: SingleChildScrollView(
                          //     child: Column(
                          //       children: [
                          //         ...restaurantTimeSlotsMap.entries.map(
                          //           (service) {
                          //             return CheckboxListTile(
                          //               value: _seletedServices
                          //                   .contains(service.key),
                          //               contentPadding:
                          //                   const EdgeInsets.symmetric(
                          //                       vertical: 0, horizontal: 20),
                          //               controlAffinity:
                          //                   ListTileControlAffinity.trailing,
                          //               title: Text(
                          //                 service.key,
                          //                 style: const TextStyle(
                          //                     fontSize: 16,
                          //                     fontWeight: FontWeight.bold),
                          //               ),
                          //               onChanged: (value) {
                          //                 setState(() {
                          //                   if (value!) {
                          //                     _seletedServices.add(service.key);
                          //                   } else {
                          //                     _seletedServices
                          //                         .remove(service.key);
                          //                   }
                          //                 });
                          //               },
                          //             );
                          //           },
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          Divider(
                            thickness: 1,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // widget.onServicesChanged(_seletedServices);
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                child: const Text("Áp dụng"),
                              ),
                              const SizedBox(width: 20),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                      null,
                      false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text('Tạo chuyến đi',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
