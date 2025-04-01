import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/core/utils/show_snackbar.dart';
import 'package:vievu/features/chat/domain/entities/message.dart';
import 'package:vievu/features/chat/presentation/bloc/message_bloc.dart';
import 'package:vievu/features/search/domain/entities/explore_search_result.dart';
import 'package:vievu/features/search/presentation/bloc/search_bloc.dart';
import 'package:vievu/features/trips/domain/entities/saved_services.dart';

class AddPlaceByNameModal extends StatefulWidget {
  final String searchKey;
  final Message message; //

  const AddPlaceByNameModal({
    super.key,
    required this.message,
    required this.searchKey,
  });

  @override
  State<AddPlaceByNameModal> createState() => _AddPlaceByNameModalState();
}

class _AddPlaceByNameModalState extends State<AddPlaceByNameModal> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final List<SavedService> _seletedServices = [];
  void _onSearchChanged(String keyword) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      context.read<SearchBloc>().add(SearchAll(
            searchText: keyword,
            limit: 10,
            offset: 0,
          ));
    });
  }

  final List<ExploreSearchResult> _searchResults = [];
  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchKey;
    _onSearchChanged(widget.searchKey);
  }

  List<int> getNotEmptyTypeIds(List<SavedService> services) {
    return [-1, ...services.map((service) => service.typeId).toSet()];
  }

  @override
  Widget build(BuildContext context) {
    log(_seletedServices.toString());
    return Scaffold(
      appBar: AppBar(
        leading: null,
        centerTitle: true,
        toolbarHeight: 70,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const Text("Thêm thông tin cho địa điểm"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(
            thickness: 1,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: BlocConsumer<SearchBloc, SearchState>(
        listener: (context, state) {
          if (state is SearchSuccess) {
            setState(() {
              _searchResults.clear();
              _searchResults.addAll(state.results);
            });
          }
        },
        builder: (context, state) {
          return Container(
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Nhập để tìm địa điểm',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: state is SearchLoading
                        ? Container(
                            width: 30,
                            alignment: Alignment.center,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    if (value.trim().isNotEmpty) _onSearchChanged(value);
                  },
                ),
                if (_searchResults.isNotEmpty)
                  Column(
                    children: _searchResults
                        .map((result) => ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: CachedNetworkImage(
                                  width: 40,
                                  height: 40,
                                  imageUrl: result.cover ?? '',
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                    'assets/images/trip_placeholder.avif', // Fallback if loading fails
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              trailing: Icon(
                                result.isSaved
                                    ? Icons.favorite
                                    : Icons.favorite_outline,
                                color: result.isSaved ? Colors.redAccent : null,
                              ),
                              title: Text(result.title),
                              onTap: () {
                                // new content = replace the old content's searhKey with the selected result
                                final newContent = widget.message.content
                                    .replaceFirst(
                                        widget.searchKey, result.title);
                                final newMetadata =
                                    widget.message.metaData ?? [];

                                // if selected result in metadata replace  it with the new result
                                if (newMetadata.isNotEmpty) {
                                  final index = newMetadata.indexWhere(
                                      (element) =>
                                          element['title'] == widget.searchKey);
                                  if (index != -1) {
                                    newMetadata.removeAt(index);
                                  }
                                }
                                newMetadata.add(result.toMap());
                                context.read<MessageBloc>().add(
                                      UpdateMessageContent(
                                        messageId: widget.message.id,
                                        content: newContent,
                                        metaData: newMetadata,
                                      ),
                                    );
                                showSnackbar(context, 'Đã thêm địa điểm');
                                Navigator.of(context).pop();
                              },
                            ))
                        .toList(),
                  )
              ],
            ),
          );
        },
      ),
    );
  }
}
