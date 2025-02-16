import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:vn_travel_companion/core/layouts/custom_appbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/explore/domain/entities/review.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/reviews/reviews_cubit.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/filter_options_big.dart';
import 'package:vn_travel_companion/features/explore/presentation/widgets/reviews/review_item.dart';

class ReviewsPage extends StatefulWidget {
  final int attractionId;
  const ReviewsPage({super.key, required this.attractionId});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  final PagingController<int, Review> _pagingController =
      PagingController(firstPageKey: 0);

  final List<String> _filterOptions = [
    'Mới nhất',
    'Có ảnh',
    'Đơn đặt đã xác thực',
    'Tích cực',
    'Tiêu cực',
  ];

  int totalRecordCount = 0;
  String _selectedFilter = '';
  final int pageSize = 10;

  int _convertFilterToCommentTagId(String filter) {
    return filter == 'Mới nhất'
        ? -1
        : filter == 'Có ảnh'
            ? -21
            : filter == 'Đơn đặt đã xác thực'
                ? -30
                : filter == 'Tích cực'
                    ? -11
                    : filter == 'Tiêu cực'
                        ? -12
                        : 0;
  }

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      context.read<ReviewsCubit>().fetchReviewsAll(
          attractionId: widget.attractionId,
          limit: pageSize,
          pageIndex: (pageKey ~/ pageSize) + 1,
          commentTagId: _convertFilterToCommentTagId(_selectedFilter));
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pagingController.dispose();
  }

  void _onFilterChanged(String selectedFilter) {
    setState(() {
      if (_selectedFilter == selectedFilter) {
        _selectedFilter =
            ''; // Reset to '' if the same filter is selected again
      } else {
        _selectedFilter = selectedFilter;
      }

      totalRecordCount = 0; // Reset total record count for new search
    });

    // Reset paging controller to fetch new data based on selected filter
    _pagingController.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbar(
        appBarTitle: 'Đánh giá & Bình luận',
        centerTitle: true,
        body: BlocConsumer<ReviewsCubit, ReviewsState>(
          listener: (context, state) {
            if (state is ReviewsFailure) {
              log(state.message.toString());
            }
            if (state is ReviewsAllLoadedSuccess) {
              totalRecordCount += state.reviews.length;
              final next = totalRecordCount;
              final isLastPage = state.reviews.length < pageSize;
              if (isLastPage) {
                _pagingController.appendLastPage(state.reviews);
              } else {
                _pagingController.appendPage(state.reviews, next);
              }
            }
          },
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: FilterOptionsBig(
                          options: _filterOptions,
                          selectedOption: _selectedFilter,
                          onOptionSelected: _onFilterChanged,
                          isFiltering: state is ReviewsLoading)),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(
                      bottom: 70.0, left: 20, right: 20, top: 20),
                  sliver: PagedSliverList<int, Review>(
                    pagingController: _pagingController,
                    builderDelegate: PagedChildBuilderDelegate<Review>(
                      itemBuilder: (context, item, index) {
                        return ReviewItem(
                          review: item,
                        );
                      },
                      firstPageProgressIndicatorBuilder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                      newPageProgressIndicatorBuilder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                      noItemsFoundIndicatorBuilder: (_) =>
                          const Center(child: Text('Không có đánh giá nào.')),
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
        ));
  }
}
