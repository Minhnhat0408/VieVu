import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/hotel.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/nearby_services/nearby_services_cubit.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/hotels/hotel_price_modal.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/hotels/hotel_room_info_modal.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/hotels/hotel_small_card.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/hotels/hotel_star_modal.dart';

class HotelListPage extends StatefulWidget {
  final String locationName;
  const HotelListPage({
    super.key,
    required this.locationName,
  });

  @override
  State<HotelListPage> createState() => _HotelListPageState();
}

class _HotelListPageState extends State<HotelListPage> {
  final PagingController<int, Hotel> _pagingController =
      PagingController(firstPageKey: 0);

  int? _star;
  int _roomQuantity = 1;
  int _adultCount = 2;
  int _childCount = 0;
  int? _minPrice;
  int? _maxPrice;

  final int pageSize = 10;
  int totalRecordCount = 0;
  DateTimeRange selectedDateRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now().add(const Duration(days: 1)),
  );

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      initialDateRange: selectedDateRange,
      locale: const Locale('vi', 'VN'),
    );
    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
      });
      totalRecordCount = 0;
      _pagingController.refresh();
    }
  }

  final options = ["Khách sạn", "Ngày", "Khoảng giá", "Sao", "Tùy chọn phòng"];
  IconData _convertIcon(int index) {
    switch (index) {
      case 0:
        return Icons.close;
      default:
        return Icons.arrow_drop_down_circle_outlined;
    }
  }

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      context.read<NearbyServicesCubit>().getHotelsWithFilter(
            checkInDate: selectedDateRange.start,
            checkOutDate: selectedDateRange.end,
            roomQuantity: _roomQuantity,
            adultCount: _adultCount,
            childCount: _childCount,
            star: _star,
            limit: pageSize,
            offset: pageKey,
            minPrice: _minPrice,
            maxPrice: _maxPrice,
            locationName: widget.locationName,
          );
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pagingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.locationName),
        centerTitle: true,
      ),
      body: Stack(children: [
        NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              floating: true,
              leading: null,
              automaticallyImplyLeading: false,
              snap: true,
              scrolledUnderElevation: 0,
              flexibleSpace: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6),
                  child: Row(
                    children: List.generate(
                      options.length, // Number of buttons
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: index == 0
                            ? Hero(
                                tag: options[index],
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        options[index],
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        _convertIcon(index),
                                        size: 20,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : OutlinedButton(
                                onPressed: () {
                                  if (options[index] == "Khoảng giá") {
                                    displayModal(
                                        context,
                                        HotelPriceModal(
                                          maxPrice: _maxPrice,
                                          minPrice: _minPrice,
                                          onServicesChanged: (newServices) {
                                            setState(() {
                                              _maxPrice =
                                                  newServices[1].round();
                                              _minPrice =
                                                  newServices[0].round();
                                              totalRecordCount = 0;
                                              _pagingController.refresh();
                                            });
                                          },
                                        ),
                                        null,
                                        false);
                                  } else if (options[index] == "Sao") {
                                    displayModal(
                                        context,
                                        HotelStarModal(
                                          currentRating: _star,
                                          onRatingChanged: (newRating) {
                                            setState(() {
                                              _star = newRating;
                                              totalRecordCount = 0;
                                              _pagingController.refresh();
                                            });
                                          },
                                        ),
                                        null,
                                        false);
                                  } else if (options[index] == "Ngày") {
                                    _selectDateRange(context);
                                  } else {
                                    displayModal(
                                        context,
                                        HotelRoomInfoModal(
                                          roomQuantity: _roomQuantity,
                                          adultCount: _adultCount,
                                          childCount: _childCount,
                                          onRoomInfoChanged: (newRoomInfo) {
                                            setState(() {
                                              _roomQuantity = newRoomInfo[0];
                                              _adultCount = newRoomInfo[1];
                                              _childCount = newRoomInfo[2];
                                              totalRecordCount = 0;
                                              _pagingController.refresh();
                                            });
                                          },
                                        ),
                                        null,
                                        false);
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.surface,
                                  side: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: (options[index] == "Khoảng giá" &&
                                                (_minPrice != null ||
                                                    _maxPrice != null)) ||
                                            (options[index] == "Sao" &&
                                                _star != null) ||
                                            (options[index] == "Ngày" &&
                                                index == 1) ||
                                            (options[index] ==
                                                    "Tùy chọn phòng" &&
                                                (_roomQuantity != 1 ||
                                                    _adultCount != 2 ||
                                                    _childCount != 0))
                                        ? 2.0
                                        : 1.0, // Thicker border
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      index != 1
                                          ? options[index]
                                          : "${DateFormat('dd/MM/yyyy').format(selectedDateRange.start)}-${DateFormat('dd/MM/yyyy').format(selectedDateRange.end)}",
                                      style: TextStyle(
                                        fontWeight: (options[index] ==
                                                        "Khoảng giá" &&
                                                    (_minPrice != null ||
                                                        _maxPrice != null)) ||
                                                (options[index] == "Sao" &&
                                                    _star != null) ||
                                                (options[index] == "Ngày" &&
                                                    index == 1) ||
                                                (options[index] ==
                                                        "Tùy chọn phòng" &&
                                                    (_roomQuantity != 1 ||
                                                        _adultCount != 2 ||
                                                        _childCount != 0))
                                            ? FontWeight.bold
                                            : FontWeight.normal, // Bold text
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      _convertIcon(index),
                                      size: 20,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
          body: BlocConsumer<NearbyServicesCubit, NearbyServicesState>(
            listener: (context, state) {
              if (state is HotelLoadedSuccess) {
                totalRecordCount += state.hotels.length;
                final next = totalRecordCount;
                final isLastPage = state.hotels.length < pageSize;
                if (isLastPage) {
                  _pagingController.appendLastPage(state.hotels);
                } else {
                  _pagingController.appendPage(state.hotels, next);
                }
              }
            },
            builder: (context, state) {
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 70),
                    sliver: PagedSliverList<int, Hotel>(
                      pagingController: _pagingController,
                      builderDelegate: PagedChildBuilderDelegate<Hotel>(
                        itemBuilder: (context, item, index) {
                          return HotelSmallCard(hotel: item);
                        },
                        firstPageProgressIndicatorBuilder: (_) =>
                            const Center(child: CircularProgressIndicator()),
                        newPageProgressIndicatorBuilder: (_) =>
                            const Center(child: CircularProgressIndicator()),
                        noItemsFoundIndicatorBuilder: (_) => const Center(
                            child: Text('Không có điểm du lịch nào.')),
                        newPageErrorIndicatorBuilder: (context) => Center(
                          child: TextButton(
                            onPressed: () =>
                                _pagingController.retryLastFailedRequest(),
                            child: const Text('Thử lại'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Positioned(
          bottom: 70.0,
          right: 16.0,
          child: FloatingActionButton(
            onPressed: () {
              // Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (context) => const MapView(),
              //   ),
              // );
            },
            child: const Icon(Icons.map),
          ),
        ),
      ]),
    );
  }
}

void displayModal(
    BuildContext context, Widget child, double? height, bool expand) {
  showBarModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    useRootNavigator: true,
    enableDrag: true,
    topControl: Container(
      width: 40,
      height: 5,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(5),
      ),
    ),
    expand: expand,
    builder: (context) =>
        height != null ? SizedBox(height: height, child: child) : child,
  );
}
